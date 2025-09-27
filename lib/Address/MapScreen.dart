import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../../constant/all.dart';
import 'add_address.dart';

class MapScreen extends StatefulWidget {

  MapScreen({Key? key})
      : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final TextEditingController addressController = TextEditingController();
  final TextEditingController searchController = TextEditingController();
  final MapController _mapController = MapController();

  Position? _currentPosition;
  LatLng? currentLatLng;
  String? locationName;
  String? pinCode;
  String? city;
  String? state;
  Placemark? place;

  bool _isFetchingAddress = false;
  bool _isAddressConfirmed = false;
  bool _shouldMoveToInitial = false;

  @override
  void initState() {
    super.initState();

    _getCurrentLocation();
  }

  @override
  void dispose() {
    addressController.dispose();
    searchController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied.');
      }
    }

    _currentPosition = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    currentLatLng =
        LatLng(_currentPosition!.latitude, _currentPosition!.longitude);

    await _getAddressFromLatLng(currentLatLng!);
    setState(() {});
  }

  Future<void> _getAddressFromLatLng(LatLng latLng) async {
    setState(() {
      _isFetchingAddress = true;
    });

    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latLng.latitude,
        latLng.longitude,
      );

      if (placemarks.isNotEmpty) {
        place = placemarks.first;
        setState(() {
          locationName = place?.subLocality?.isNotEmpty == true
              ? place?.subLocality
              : place?.locality ?? 'Unknown Location';

          pinCode = place?.postalCode;
          city = place?.locality;
          state = place?.administrativeArea;

          addressController.text = [
            place?.subLocality,
            place?.locality,
            place?.postalCode,
            place?.country
          ]
              .where((element) => element != null && element!.isNotEmpty)
              .join(', ');
        });
      } else {
        setState(() {
          locationName = 'Unknown Location';
          addressController.text = 'Address not found';
        });
      }
    } catch (e) {
      print('Error in reverse geocoding: $e');
      setState(() {
        locationName = 'Error fetching location';
        addressController.text = '';
      });
    } finally {
      setState(() {
        _isFetchingAddress = false;
      });
    }
  }

  void _confirmLocation() {
    /*if (addressController.text.isNotEmpty && pinCode != null) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        builder: (context) =>
            FractionallySizedBox(
              heightFactor: 0.9,
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                child: AddAddressScreen(
                  address: addressController.text,
                  pinCode: pinCode,
                  currentLatLng: currentLatLng,
                  city: city,
                  state: state,
                  onConfirm : (address,currentLatLng){
                    Navigator.pop(context,currentLatLng);
                  }
                ),
              ),
            ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
            Text('Address or Pin Code not available. Please try again.')),
      );
    }*/
    Navigator.pop(context,currentLatLng);
  }

  Future<void> _searchLocation() async {
    String query = searchController.text.trim();
    if (query.isEmpty) return;

    try {
      List<Location> locations = await locationFromAddress(query);

      if (locations.isNotEmpty) {
        LatLng searchedLatLng =
            LatLng(locations.first.latitude, locations.first.longitude);

        setState(() {
          currentLatLng = searchedLatLng;
        });

        _mapController.move(searchedLatLng, 15.0);
        _getAddressFromLatLng(searchedLatLng);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Location not found. Please try another query.')),
        );
      }
    } catch (e) {
      print('Search Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Failed to find the location. Please check the query.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Safe map move after widget is built
    if (_shouldMoveToInitial && currentLatLng != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        try {
          _mapController.move(currentLatLng!, 15.0);
          _getAddressFromLatLng(currentLatLng!);
        } catch (e) {
          print('MapController move error: $e');
        }
        _shouldMoveToInitial = false;
      });
    }

    return Scaffold(
      appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white), // 👈 force white
            onPressed: () => Navigator.pop(context),
          ),
        title: _isAddressConfirmed
            ? const Text('Add Address')
            : TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: 'Search for a building, street name or area',
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                ),
                onSubmitted: (value) => _searchLocation(),
              ),
        backgroundColor: AppColors.kPrimary
      ),
      body:  _isAddressConfirmed
          ? AddAddressScreen(
        address: addressController.text,
        pinCode: pinCode,
        currentLatLng: currentLatLng,
        city: city,
        state: state,
          onConfirm : (address,currentLatLng){
            Navigator.pop(context,currentLatLng);
          }
      )
          :currentLatLng == null
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    Expanded(
                      child: Stack(
                        children: [
                          FlutterMap(
                            mapController: _mapController,
                            options: MapOptions(
                              center: currentLatLng,
                              zoom: 15.0,
                              onMapEvent: (event) {
                                if (event is MapEventMoveEnd) {
                                  LatLng center = _mapController.center;
                                  currentLatLng = center;
                                  _getAddressFromLatLng(center);
                                }
                              },
                            ),
                            children: [
                              TileLayer(
                                urlTemplate:
                                    "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                                subdomains: ['a', 'b', 'c'],
                              ),
                            ],
                          ),
                          const Center(
                            child: Icon(Icons.location_on,
                                color: Colors.red, size: 40),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_isFetchingAddress)
                            const Center(child: CircularProgressIndicator())
                          else
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.location_on,
                                    color: AppColors.kPrimary),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        locationName ?? 'Unknown Location',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        addressController.text,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      _isAddressConfirmed = false;
                                    });
                                  },
                                  style: TextButton.styleFrom(
                                      padding: EdgeInsets.zero),
                                  child: const Text(
                                    'CHANGE',
                                    style: TextStyle(
                                      color: AppColors.kPrimary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed:
                                _isFetchingAddress ? null : _confirmLocation,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.kPrimary,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Center(
                              child: Text(
                                "CONFIRM LOCATION",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }
}
