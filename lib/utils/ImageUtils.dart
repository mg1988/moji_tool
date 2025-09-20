import 'package:image_picker/image_picker.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';
import 'package:file_selector/file_selector.dart';
class Imageutils {
  static Future<void> getLostData(Function hanler) async {
    final ImagePicker picker = ImagePicker();
    final LostDataResponse response = await picker.retrieveLostData();
    if (response.isEmpty) {
      return;
    }
    final List<XFile>? files = response.files;
    if (files != null) {
      hanler(file: files);
    } else {
      hanler(error: response.exception);
    }
  }

  static Future<void> pickImage(Function hanler) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    hanler(image);
  }

  static Future<void> pickFile(Function handler) async {
    const XTypeGroup typeGroup = XTypeGroup(
      label: 'pdf',
      extensions: <String>['pdf', 'txt', 'doc', 'docx'],
    );
    final XFile? file =
        await openFile(acceptedTypeGroups: <XTypeGroup>[typeGroup]);
        handler(file);
  }
//   final ImagePicker picker = ImagePicker();
// // Pick an image.
// final XFile? image = await picker.pickImage(source: ImageSource.gallery);
// // Capture a photo.
// final XFile? photo = await picker.pickImage(source: ImageSource.camera);
// // Pick a video.
// final XFile? galleryVideo =
//     await picker.pickVideo(source: ImageSource.gallery);
// // Capture a video.
// final XFile? cameraVideo = await picker.pickVideo(source: ImageSource.camera);
// // Pick multiple images.
// final List<XFile> images = await picker.pickMultiImage();
// // Pick singe image or video.
// final XFile? media = await picker.pickMedia();
// // Pick multiple images and videos.
// final List<XFile> medias = await picker.pickMultipleMedia();
}
