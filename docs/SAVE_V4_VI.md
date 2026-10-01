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

Save cũ `user://englishfarm_journey_v3.json` chỉ được nhận là Journey V3 khi đồng thời có `version=1` và `journey_version=1`. File cũ không bị xóa. Migration chỉ hoàn tất khi autosave V4 đã ghi và đọc kiểm tra thành công. Sau đó `v3_migrated.flag` được tạo để việc Reset/Xóa V4 không vô tình phục hồi lại save V3 ở lần mở kế tiếp.

Cơ chế timestamp cây V3 hiện **không bị đổi thang** trong nhánh này. Chế độ nhanh vẫn dùng cùng `crop_time()` và cùng timestamp cũ, tránh làm cây V3 đổi tuổi đột ngột sau migration. Chế độ thực tiếp tục dùng Unix time của máy.

## Autosave

- Sau giao dịch, nhiệm vụ, vào/ra phòng, thay đổi cài đặt.
- Chu kỳ khoảng 30 giây khi Momo đã di chuyển hoặc giao hàng đang chạy.
- Thư nháp debounce 1 giây; đóng màn thư/thoát game flush bản cuối.
- Không ghi mỗi frame.

## Menu

Menu mở game: Tiếp tục, Game mới, Tải game, Cài đặt, Thoát. Game mới thay autosave nhưng giữ ba ô thủ công. Settings có Lưu/Tải/Xóa từng ô, xuất JSON, nhập JSON, reset autosave và xóa toàn bộ V4.

Import giới hạn 1 MiB và chỉ chấp nhận envelope V4 hợp lệ; nội dung JSON không được dùng làm đường dẫn và không thực thi mã.


## Giới hạn binary V4 trong PR

Nhánh `codex/v4-runtime-save-rebuild` chứa mã tích hợp, test và script dựng asset. Các WebP V4 được tạo từ ZIP người dùng phải nằm trong `game/assets/v4/rooms/` và `game/assets/v4/guides/`. Nếu chúng chưa có, mã tự dùng fallback procedural/text để project vẫn chạy và CI vẫn kiểm tra logic. Bản phát hành hình ảnh V4 chỉ được coi là hoàn chỉnh sau khi binary pack đã được chép vào đúng các đường dẫn này và chạy lại kiểm tra trực quan.
