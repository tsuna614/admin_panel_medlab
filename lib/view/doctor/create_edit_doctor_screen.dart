import 'package:admin_panel_medlab/bloc/doctor-bloc/doctor_bloc.dart';
import 'package:admin_panel_medlab/bloc/doctor-bloc/doctor_events.dart';
import 'package:admin_panel_medlab/bloc/doctor-bloc/doctor_states.dart';
import 'package:flutter/material.dart';
import 'package:admin_panel_medlab/models/doctor_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // Assuming your Doctor model is here

class CreateEditDoctorScreen extends StatefulWidget {
  final Doctor? doctorToEdit; // Null if creating, has value if editing

  const CreateEditDoctorScreen({super.key, this.doctorToEdit});

  @override
  State<CreateEditDoctorScreen> createState() => _CreateEditDoctorScreenState();
}

class _CreateEditDoctorScreenState extends State<CreateEditDoctorScreen> {
  final _formKey = GlobalKey<FormState>();

  // Text Editing Controllers for each field
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _medicalSpecialtyController;
  late TextEditingController _startingYearController;
  late TextEditingController _qualificationsController;
  late TextEditingController _shortBioController;
  late TextEditingController _consultationFeeRangeController;
  late TextEditingController _profileImageUrlController;

  bool _isVisibleToUsers = true;
  bool _isLoading = false; // For a loading indicator when saving

  @override
  void initState() {
    super.initState();
    final p = widget.doctorToEdit;
    _firstNameController = TextEditingController(text: p?.firstName ?? '');
    _lastNameController = TextEditingController(text: p?.lastName ?? '');
    _medicalSpecialtyController = TextEditingController(
      text: p?.medicalSpecialty ?? '',
    );
    _startingYearController = TextEditingController(
      text: p?.startingYear.toString() ?? '',
    );
    _qualificationsController = TextEditingController(
      text: p?.qualifications ?? '',
    );
    _shortBioController = TextEditingController(text: p?.shortBio ?? '');
    _consultationFeeRangeController = TextEditingController(
      text: p?.consultationFeeRange ?? '',
    );
    _profileImageUrlController = TextEditingController(
      text: p?.profileImageUrl ?? '',
    );
    _isVisibleToUsers = p?.isVisibleToUsers ?? true; // Default to true if null
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _medicalSpecialtyController.dispose();
    _startingYearController.dispose();
    _qualificationsController.dispose();
    _shortBioController.dispose();
    _consultationFeeRangeController.dispose();
    _profileImageUrlController.dispose();
    super.dispose();
  }

  void _saveDoctor() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save(); // Triggers onSaved for FormFields if used

      setState(() {
        _isLoading = true; // Show loading indicator
      });

      // Construct the Doctor object (or a DTO for API)
      // For now, just printing. Later, call BLoC event / Service method.
      final isEditing = widget.doctorToEdit != null;

      final doctorData = Doctor(
        id: isEditing ? widget.doctorToEdit!.id : '',
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        profileImageUrl: _profileImageUrlController.text.trim(),
        medicalSpecialty: _medicalSpecialtyController.text.trim(),
        qualifications: _qualificationsController.text.trim(),
        startingYear: int.tryParse(_startingYearController.text.trim()) ?? 2020,
        shortBio: _shortBioController.text.trim(),
        consultationFeeRange: _consultationFeeRangeController.text.trim(),
        isVisibleToUsers: _isVisibleToUsers,
      );

      print('Saving Doctor: ${doctorData.firstName}');
      print('Is Editing: $isEditing');
      // In a real app:
      if (isEditing) {
        context.read<DoctorBloc>().add(UpdateDoctorEvent(doctor: doctorData));
      } else {
        context.read<DoctorBloc>().add(
          CreateDoctorEvent(doctor: doctorData),
        ); // Might not need ID here
      }

      final result = await BlocProvider.of<DoctorBloc>(context).stream
          .firstWhere(
            (state) => state is DoctorsLoaded || state is DoctorError,
          );

      if (!mounted) return;

      setState(() {
        _isLoading = false; // Hide loading indicator
      });

      if (result is DoctorError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${result.message}'),
            backgroundColor: Colors.red,
          ),
        );
      } else if (result is DoctorsLoaded) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Doctor ${isEditing ? "updated" : "created"} successfully!',
            ),
          ),
        );
        Navigator.of(context).pop(); // Go back after saving
      }

      // // Simulate save and pop
      // Future.delayed(const Duration(seconds: 1), () {
      //   setState(() {
      //     _isLoading = false;
      //   });
      //   if (mounted) {
      //     ScaffoldMessenger.of(context).showSnackBar(
      //       SnackBar(
      //         content: Text(
      //           'Doctor ${isEditing ? "updated" : "created"} successfully (simulated)!',
      //         ),
      //       ),
      //     );
      //     Navigator.of(context).pop(); // Go back after "saving"
      //   }
      // });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.doctorToEdit != null;
    final appBarTitle = isEditing ? 'Edit Doctor' : 'Create Doctor';

    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.only(right: 16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveDoctor,
              tooltip: 'Save Doctor',
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            // Use ListView for scrollability if form is long
            children: <Widget>[
              _buildTextFormField(
                controller: _firstNameController,
                labelText: "Doctor's First Name",
                icon: Icons.person,
              ),
              _buildTextFormField(
                controller: _lastNameController,
                labelText: "Doctor's Last Name",
                icon: Icons.person_outline,
              ),
              _buildTextFormField(
                controller: _medicalSpecialtyController,
                labelText: "Medical Specialty",
                icon: Icons.medical_services,
              ),
              _buildTextFormField(
                controller: _startingYearController,
                labelText: "Starting Year",
                icon: Icons.calendar_today,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a starting year';
                  }
                  final year = int.tryParse(value);
                  if (year == null ||
                      year < 1900 ||
                      year > DateTime.now().year) {
                    return 'Please enter a valid year';
                  }
                  return null;
                },
              ),
              _buildTextFormField(
                controller: _qualificationsController,
                labelText: "Qualifications",
                icon: Icons.school,
              ),
              _buildTextFormField(
                controller: _shortBioController,
                labelText: "Short Bio",
                icon: Icons.info_outline,
                maxLines: 3,
              ),
              _buildTextFormField(
                controller: _consultationFeeRangeController,
                labelText: "Consultation Fee Range",
                icon: Icons.attach_money,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a consultation fee range';
                  }
                  // You can add more validation logic here if needed
                  return null;
                },
              ),
              _buildTextFormField(
                controller: _profileImageUrlController,
                labelText: "Profile Image URL",
                icon: Icons.image,
                readOnly: isEditing, // Make read-only if editing
                validator: (value) {
                  if (isEditing) return null; // Skip validation if editing
                  if (value == null || value.isEmpty) {
                    return 'Please enter a profile image URL';
                  }
                  // You can add more validation logic here if needed
                  return null;
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    Checkbox(
                      value: _isVisibleToUsers,
                      onChanged: (value) {
                        setState(() {
                          _isVisibleToUsers = value ?? true;
                        });
                      },
                    ),
                    const Text('Visible to Users'),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _saveDoctor,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(
                    double.infinity,
                    60,
                  ), // Make button wide
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  foregroundColor: Colors.white,
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3,
                        ),
                      )
                    : Text(
                        isEditing ? 'Update Doctor' : 'Create Doctor',
                        style: const TextStyle(fontSize: 16),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper widget to build TextFormFields consistently
  Widget _buildTextFormField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    int maxLines = 1,
    bool readOnly = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.1),
        ),
        keyboardType: keyboardType,
        validator: validator,
        maxLines: maxLines,
        readOnly: readOnly,
        // onTap: readOnly
        //     ? () => _selectExpiryDate(context)
        //     : null, // Trigger date picker if readOnly is for date
      ),
    );
  }
}
