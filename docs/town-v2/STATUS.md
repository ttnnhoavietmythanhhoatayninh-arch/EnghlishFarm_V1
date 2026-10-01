# Trạng thái 01/10/2026 — Town V2

Hoàn tất bản dùng thử Windows x86_64: EnglishFarm.exe + EnglishFarm.pck. Mã nguồn, concept trước đây, map mới, JSON mẫu, Pixelixe và Remotion được giữ trong bộ source. File cache/node_modules, credential và bộ cài engine không phải source dự án và không đóng gói.

## Bằng chứng
- test_learning: 0 lỗi state.
- test_learning_ui: passed.
- test_game kế thừa: passed.
- test_town: mọi điểm NPC/nhà/cổng được kiểm tra đường đi nối với quảng trường; fountain bị chặn; thưởng đơn hàng không nhận hai lần.
- test_town_ui: đọc → mở 3 hạt → trồng/thu hoạch → giao hàng → nâng cấp; khôi phục save, bản nháp thư, mở/đóng map.
- Godot 4.3 export Windows thành công. Gói PCK khởi động headless không có lỗi.
- Chưa chạy EXE trên Windows thật, chưa kiểm tra giao diện qua GPU hoặc thử người học. Không biến kết quả headless thành kết luận kiểm thử hình ảnh.

## Quyết định thiết kế
Momo là mèo duy nhất có vai trò nhân vật. NPC người. Quảng trường trung tâm; nhà Momo ở một góc thị trấn. Nội dung học chỉ đọc/viết/từ vựng/ngữ pháp. Ngoại tuyến. Tiền Word Cards, hỗ trợ Powers. Dữ liệu lưu tại user://englishfarm_town_v2.json; tách file V1. Thư lưu trên máy, không gửi tới máy chủ.

Chế độ thử mặc định cây 20s, héo sau 60s không tưới; thời gian thực 12h tùy chọn khi ruộng trống. Login/ôn từ không bị tăng tốc. Cần đồng hồ thiết bị đáng tin cậy; chưa chống chỉnh đồng hồ.

## GitHub còn bị chặn
Người dùng được báo có quyền quản trị/push, nhưng kết nối ứng dụng trả 403 khi thực thi create_file. Không dùng đường khác để vượt qua quyền của ứng dụng. Không có commit/tệp trên repo đích được tạo trong phiên. Local commit và ZIP đã sẵn sàng để chuyển sau khi quyền ứng dụng được sửa.

## Giới hạn sản phẩm
6 NPC dùng 3 sprite người, đứng tại vị trí cố định. Chỉ 1 chuỗi đơn hàng. Công cụ cấp2 chưa tăng hiệu suất. Một loại cây 12h. Câu cá, nội thất, thời tiết, mùa, tùy biến, AI chấm, 24h crops, các loại power nâng cao, lịch NPC và mobile còn ở backlog. Bài học9 từ/3 đoạn đọc là mẫu chưa thẩm định CEFR. Artwork mới là nền nguyên khối; cây/NPC tương tác là lớp riêng. Không coi mô hình ảnh là mô hình ML tự huấn luyện.
