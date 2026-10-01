# Save/Load V4 – hướng dẫn vận hành

## Vị trí dữ liệu

Godot ghi vào `user://saves/englishfarm_v4/`:

- `autosave.json`: tự lưu.
- `slot_1.json` đến `slot_3.json`: ba ô lưu thủ công.
- `.bak`: bản tốt trước lần ghi mới.
- `.tmp`: file tạm trong lúc ghi.

Không ghi tiến trình vào `res://` hoặc cạnh EXE.

## Dữ liệu

Envelope V4 có `schema_version=4`, `content_version`, `save_id`, `slot_id`, `saved_at`, toàn bộ state Journey và context vị trí. Vector2 được chuyển thành `{"x":...,"y":...}`.

Tải game đọc/parse/kiểm tra envelope trước, tạo state tạm, rồi mới thay state đang chơi. File chính hỏng hoặc không hợp lệ sẽ thử `.bak`. Nếu cả hai hỏng, phiên hiện tại không bị thay.

## Migration V3

Save cũ `user://englishfarm_journey_v3.json` chỉ được nhận là Journey V3 khi đồng thời có `version=1` và `journey_version=1`. File cũ không bị xóa. Migration chỉ hoàn tất khi autosave V4 đã ghi và đọc kiểm tra thành công.

Cơ chế timestamp cây V3 hiện **không bị đổi thang** trong nhánh này. Chế độ nhanh vẫn dùng cùng `crop_time()` và cùng timestamp cũ, tránh làm cây V3 đổi tuổi đột ngột sau migration. Chế độ thực tiếp tục dùng Unix time của máy.

## Autosave

- Sau giao dịch, nhiệm vụ, vào/ra phòng, thay đổi cài đặt.
- Chu kỳ khoảng 30 giây khi Momo đã di chuyển hoặc giao hàng đang chạy.
- Thư nháp debounce 1 giây; đóng màn thư/thoát game flush bản cuối.
- Không ghi mỗi frame.

## Menu

Menu mở game: Tiếp tục, Game mới, Tải game, Cài đặt, Thoát. Game mới thay autosave nhưng giữ ba ô thủ công. Settings có Lưu/Tải/Xóa từng ô, xuất JSON, nhập JSON, reset autosave và xóa toàn bộ V4.

Import giới hạn 1 MiB và chỉ chấp nhận envelope V4 hợp lệ; nội dung JSON không được dùng làm đường dẫn và không thực thi mã.
