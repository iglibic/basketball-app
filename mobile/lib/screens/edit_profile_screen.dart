import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final nicknameController = TextEditingController();

  String position = "PG";
  String dominantHand = "Right";

  File? selectedImage;
  String? existingProfileImageUrl;
  bool profileImageRemoved = false;
  bool hasUnsavedChanges = false;

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  Future<void> loadUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      final response = await http.get(
        Uri.parse("http://10.0.2.2:3000/me"),
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          firstNameController.text = data["first_name"] ?? "";
          lastNameController.text = data["last_name"] ?? "";
          nicknameController.text = data["nickname"] ?? "";

          position = data["position"] ?? "PG";
          dominantHand = data["dominant_hand"] ?? "Right";
          existingProfileImageUrl = data["profile_image"];
          profileImageRemoved = false;
          selectedImage = null;
        });
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();

    final image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    print("IMAGE PATH: ${image?.path}");

    if (image != null) {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: image.path,

        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),

        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 90,

        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Profile Picture',
            toolbarColor: const Color(0xFF0D1224),
            toolbarWidgetColor: Colors.white,
            statusBarColor: const Color(0xFF0D1224),
            backgroundColor: const Color(0xFF0D1224),
            activeControlsWidgetColor: const Color(0xFF7C5CFF),

            lockAspectRatio: true,
            hideBottomControls: false,
          ),

          IOSUiSettings(
            title: 'Crop Profile Picture',
            aspectRatioLockEnabled: true,
          ),
        ],
      );

      if (croppedFile != null) {
        setState(() {
          selectedImage = File(croppedFile.path);
          profileImageRemoved = false;
          hasUnsavedChanges = true;
        });
      }
    }
  }

  Future<void> removeProfileImage() async {
    if (selectedImage != null && existingProfileImageUrl == null) {
      setState(() {
        selectedImage = null;
        profileImageRemoved = true;
        hasUnsavedChanges = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile picture removed'),
          backgroundColor: Colors.green,
        ),
      );
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      final response = await http.delete(
        Uri.parse("http://10.0.2.2:3000/delete-profile-image"),
        headers: {"Authorization": "Bearer $token"},
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        setState(() {
          selectedImage = null;
          existingProfileImageUrl = null;
          profileImageRemoved = true;
          hasUnsavedChanges = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data["message"] ?? 'Profile picture removed'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data["message"] ?? 'Could not remove picture'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to remove profile picture'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> showImageOptions() async {
    final hasImage =
        selectedImage != null ||
        (existingProfileImageUrl != null &&
            existingProfileImageUrl!.isNotEmpty);

    final action = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: const Color(0xFF171C33),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        Widget option({
          required IconData icon,
          required Color color,
          required String title,
          required VoidCallback onTap,
        }) {
          return InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  Icon(icon, color: color, size: 22),

                  const SizedBox(width: 16),

                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.white30,
                    size: 16,
                  ),
                ],
              ),
            ),
          );
        }

        return SafeArea(
          child: Container(
            decoration: const BoxDecoration(
              color: Color(0xFF11172F),
              borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 10),

                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                const SizedBox(height: 18),

                const Text(
                  "Profile Picture",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                option(
                  icon: hasImage
                      ? Icons.photo_library_outlined
                      : Icons.add_a_photo_outlined,
                  color: const Color(0xFF7C5CFF),
                  title: hasImage ? "Change Picture" : "Add Picture",
                  onTap: () => Navigator.pop(context, "change"),
                ),

                if (hasImage)
                  option(
                    icon: Icons.delete_outline_rounded,
                    color: Colors.redAccent,
                    title: "Remove Picture",
                    onTap: () => Navigator.pop(context, "remove"),
                  ),

                const SizedBox(height: 14),
              ],
            ),
          ),
        );
      },
    );

    if (action == 'change') {
      await pickImage();
    } else if (action == 'remove') {
      await removeProfileImage();
    }
  }

  Future<void> saveChanges() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      final response = await http.put(
        Uri.parse("http://10.0.2.2:3000/update-profile"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "firstName": firstNameController.text.trim(),
          "lastName": lastNameController.text.trim(),
          "nickname": nicknameController.text.trim(),
          "position": position,
          "dominantHand": dominantHand,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode != 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data["message"] ?? "Update failed"),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (selectedImage != null) {
        final uploadRequest = http.MultipartRequest(
          "POST",
          Uri.parse("http://10.0.2.2:3000/upload-profile-image"),
        );

        uploadRequest.headers["Authorization"] = "Bearer $token";

        final multipartFile = await http.MultipartFile.fromPath(
          "image",
          selectedImage!.path,
        );
        uploadRequest.files.add(multipartFile);

        final uploadResponse = await uploadRequest.send();
        final uploadBody = await uploadResponse.stream.bytesToString();

        if (uploadResponse.statusCode != 200) {
          final uploadData = jsonDecode(uploadBody);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(uploadData["message"] ?? "Image upload failed"),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        final uploadData = jsonDecode(uploadBody);
        existingProfileImageUrl = uploadData["image"];
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Profile updated successfully"),
          backgroundColor: Colors.green,
        ),
      );

      hasUnsavedChanges = false;

      Navigator.pop(context, true);
    } catch (e) {
      print(e);
    }
  }

  Future<String?> confirmDiscardChanges() async {
    if (!hasUnsavedChanges) return "discard";

    final result = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: const Color(0xFF171C33),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: const BoxDecoration(
                    color: Color(0xFF7C5CFF),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.edit_outlined,
                    color: Colors.white,
                    size: 30,
                  ),
                ),

                const SizedBox(height: 18),

                const Text(
                  "Unsaved Changes",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  "You have unsaved changes.\nWhat would you like to do?",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 15,
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 26),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, "save"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7C5CFF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      "Save Changes",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, "discard"),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.redAccent),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      "Don't Save",
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                TextButton(
                  onPressed: () => Navigator.pop(context, "cancel"),
                  child: const Text(
                    "Keep Editing",
                    style: TextStyle(
                      color: Colors.white60,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    return result;
  }

  Widget buildPositionButton(String value) {
    final selected = position == value;

    return SizedBox(
      height: 58,
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            position = value;
            hasUnsavedChanges = true;
          });
        },
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: EdgeInsets.zero,
          backgroundColor: selected
              ? const Color(0xFF7C5CFF)
              : const Color(0xFF2A3354),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: selected ? FontWeight.bold : FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget buildHandButton(String value) {
    final selected = dominantHand == value;

    return SizedBox(
      height: 58,
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            dominantHand = value;
            hasUnsavedChanges = true;
          });
        },
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: EdgeInsets.zero,
          backgroundColor: selected
              ? const Color(0xFF7C5CFF)
              : const Color(0xFF1F2640),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: selected ? FontWeight.bold : FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildInitialsFallback() {
    final f = firstNameController.text.trim();
    final l = lastNameController.text.trim();

    final initials = "${f.isNotEmpty ? f[0] : ""}${l.isNotEmpty ? l[0] : ""}"
        .toUpperCase();

    return Center(
      child: Text(
        initials.isNotEmpty ? initials : "IG",
        style: const TextStyle(
          color: Colors.white,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String? _profileImageUrl() {
    if (existingProfileImageUrl == null || existingProfileImageUrl!.isEmpty) {
      return null;
    }

    final url = existingProfileImageUrl!;
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return url;
    }
    return 'http://10.0.2.2:3000${url.startsWith('/') ? '' : '/'}$url';
  }

  Widget buildField({
    required TextEditingController controller,
    required String label,
  }) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: inputDecoration(label),
      onChanged: (_) {
        setState(() {
          hasUnsavedChanges = true;
        });
      },
    );
  }

  InputDecoration inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white54),
      filled: true,
      fillColor: const Color(0xFF1A2238),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }

  Widget sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !hasUnsavedChanges,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        final action = await confirmDiscardChanges();

        if (!mounted) return;

        switch (action) {
          case "save":
            await saveChanges();
            break;

          case "discard":
            hasUnsavedChanges = false;
            Navigator.pop(context);
            break;

          case "cancel":
          default:
            break;
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF0D1224),
        appBar: AppBar(
          backgroundColor: const Color(0xFF0D1224),
          elevation: 0,
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text(
            "Edit Profile",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Stack(
                children: [
                  GestureDetector(
                    onTap: showImageOptions,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF7C5CFF),
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xFF7C5CFF,
                            ).withValues(alpha: 0.25),
                            blurRadius: 4,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: selectedImage != null
                            ? Image.file(
                                selectedImage!,
                                width: 120,
                                height: 120,
                                fit: BoxFit.cover,
                              )
                            : (!profileImageRemoved &&
                                  _profileImageUrl() != null)
                            ? Image.network(
                                _profileImageUrl()!,
                                width: 120,
                                height: 120,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) {
                                  return _buildInitialsFallback();
                                },
                              )
                            : _buildInitialsFallback(),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: showImageOptions,
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: const Color(0xFF7C5CFF),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF0D1224),
                            width: 3,
                          ),
                        ),
                        child: const Icon(
                          Icons.add_a_photo_outlined,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              const SizedBox(height: 40),
              buildField(controller: firstNameController, label: "First Name"),
              const SizedBox(height: 16),
              buildField(controller: lastNameController, label: "Last Name"),
              const SizedBox(height: 16),
              buildField(controller: nicknameController, label: "Nickname"),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A2238),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    sectionTitle("Position"),

                    Row(
                      children: [
                        Expanded(child: buildPositionButton("PG")),
                        const SizedBox(width: 8),
                        Expanded(child: buildPositionButton("SG")),
                        const SizedBox(width: 8),
                        Expanded(child: buildPositionButton("SF")),
                        const SizedBox(width: 8),
                        Expanded(child: buildPositionButton("PF")),
                        const SizedBox(width: 8),
                        Expanded(child: buildPositionButton("C")),
                      ],
                    ),

                    const SizedBox(height: 18),

                    Divider(color: Colors.white10, thickness: 1),

                    const SizedBox(height: 18),

                    sectionTitle("Dominant Hand"),

                    Row(
                      children: [
                        Expanded(child: buildHandButton("Left")),
                        const SizedBox(width: 12),
                        Expanded(child: buildHandButton("Right")),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: saveChanges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7C5CFF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_rounded, color: Colors.white, size: 20),

                      SizedBox(width: 8),

                      Text(
                        "Save Changes",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
