# Trạng thái EnglishFarm Journey V3 — 01/10/2026

## Đã kiểm chứng
- Godot 4.3 import không lỗi script.
- 8 suite headless đạt: game, learning, learning_ui, town, town_ui, journey, journey_ui, journey_layout. Log kèm thư mục này.
- Kiểm thử Journey bao phủ chọn độ khó, khóa quiz trước bước học, tiến trình ba nhiệm vụ/cấp, chống lặp nhiệm vụ, giao hàng, ngân hàng, câu cá, nâng cấp và lưu/đọc.
- Kiểm tra geometry hộp thoại trong 1280×720 ở ba độ khó, các trang hướng dẫn và cỡ chữ lớn; nền hộp thoại sáng, NPC có đường tiếp cận.
- Xuất Windows x86_64 thành công. Kiểm tra khởi động PCK bằng Godot Linux headless.

## Chưa kiểm chứng
Chưa chạy EXE trên Windows thật và chưa chụp/duyệt hình ảnh V3 bằng renderer trong môi trường hiện tại. Headless không chứng minh chất lượng hình ảnh hoặc tương thích mọi máy. `tests/capture_journey.gd` và workflow đã chuẩn bị cho CI có màn hình ảo; chưa chạy CI do chưa đẩy được repo.

## Ánh xạ yêu cầu
| Yêu cầu | Triển khai |
|---|---|
| Easy/Normal/Hard đầu game | Chọn lần mở đầu, trước hướng dẫn; hồ sơ offline, chưa có login mạng |
| Hướng dẫn có × và mở lại | 6 trang; nút Help, F1; giải thích công cụ và phần thưởng |
| Dạy rồi test | Từ vựng, ngữ pháp, đọc, viết có trang học và cổng mở quiz |
| Tách thanh chức năng | 7 nút riêng, bỏ panel đen lớn; hộp giấy sáng |
| Map nhỏ góc phải | Panel 252×200, bản đồ bên trong 224×148 |
| NPC và nhà tương tác | 7 NPC người, tên/vai trò/quan hệ, phòng có hành động |
| Dạy từ địa điểm | Learn → Places, 8 từ có IPA, nghĩa Việt và giải thích |
| Xe giao hàng | Xe hiện và chạy tuyến 12 giây, thưởng khi tới nơi |
| Ngân hàng và câu cá | Gửi/rút cards; minigame kéo đúng vùng, thưởng một lần/ngày |
| Cấp 1 cơ bản, mở dần | Nhà gỗ nhỏ, 3 ô; mỗi cấp 3 việc, mở khu và nâng nhà/mở ruộng/mua đồ |

## Phạm vi
9 từ học chính; 3 đơn vị ngữ pháp; bài đọc và viết ở 3 độ khó; 8 từ địa điểm. Chưa phải giáo trình đầy đủ hoặc chứng nhận CEFR. TTS phát âm tùy giọng hệ điều hành; không có luyện nghe/nói hoặc ghi âm. Thư kiểm độ dài và người chơi tự kiểm, không chấm chất lượng tiếng Anh bằng AI. Nội thất là màn nút tương tác; 7 vai người dùng lại 3 sprite. Bản đồ nền ảnh, chưa là tilemap. 4 cấp nhiệm vụ, cấp 5 kết thúc chương thử. Chưa có dữ liệu thử nghiệm người học.

## GitHub
Kho đích vẫn trống khi đọc metadata ngày 01/10/2026. Lần ghi trước bị 403 Resource not accessible by integration; không thử cách ghi khác để vượt quyền. ZIP nguồn chứa script publish-github.ps1 cho máy có quyền Git hợp lệ và workflow xuất Windows.

## Tài nguyên
Nhà khởi đầu dùng town_starter.png mới. Bộ art và cấu trúc Remotion các phiên trước giữ trong nguồn; không có video Remotion mới ở V3. Không ghi lên canvas Alpix công cộng vì đó không phải kho asset của dự án.
