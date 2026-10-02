# Bước 2 — Phòng V4 và tương tác nội thất

## Phạm vi

Tiếp tục nhánh `codex/journey-v4-foundation` từ commit `1c00d8498cd18110b2150de8b7598ca665525c67`. Giữ các sửa lỗi Bước 1; không thay nhánh main, tên ứng dụng hoặc định dạng `user://englishfarm_journey_v3.json`.

## Đã sửa và bổ sung

- Sửa lỗi biên dịch Godot 4.3 do suy luận kiểu của `candidate`.
- Thay hai WebP hỏng (ngân hàng, nhà vườn) bằng PNG hợp lệ. Tách nhân vật và giao diện khỏi nền.
- Giữ năm nền sạch đã có trên nhánh. Bổ sung nền chợ Mia riêng, cùng phong cách tường xanh, viền gỗ và nắng bên phải.
- Dựng Momo và NPC người bằng sprite động riêng. Nhà chính không có bản sao Momo. NPC có tên và vai trò; vị trí đứng nằm ngoài đồ đạc.
- Định nghĩa riêng vùng hình ảnh của đồ vật, vùng cấm đi và điểm đứng để tương tác. Không đo khoảng cách tới tâm bàn/tủ nữa.
- Nhấp đồ vật: Momo đi tới điểm tiếp cận rồi mở chức năng. Bàn phím: đến gần và nhấn E. Nhấp NPC hoặc nhấn E gần NPC để nói chuyện.
- Tìm đường trong phòng bằng AStarGrid2D, kiểm tra toàn bộ đoạn di chuyển mỗi 4 px; di chuyển bàn phím trượt dọc vật cản. Giữ khoảng trống từ cửa đến các điểm tương tác.
- Tạm dừng bộ điều khiển ngoài trời khi ở trong phòng, phát hoạt ảnh đi bộ theo hướng, khôi phục điều khiển ngoài trời khi ra phòng.
- Hộp thoại chặn di chuyển và hủy đường đi đang chờ. Không tự tiếp tục một hành động cũ sau khi đóng hộp thoại.
- Sáu nút trong phòng: Farm | Letters | Settings | Tasks | Map | ? Help. Căn đều ở y = 620, kích thước 170 × 78, có normal/hover/pressed/disabled. Nút ra ngoài vẫn ở y = 540.
- Giữ thư viện khóa đến cấp 2; Lily vẫn dạy ngoài trời ở cấp 1.

## Ánh xạ phòng và chức năng

| Phòng | Nền runtime | Tương tác |
|---|---|---|
| Nhà chính | 01-home.webp | Bàn học → Learn; tủ → Shop |
| Lily | 02-library.webp | Kệ → Vocabulary; bàn → Reading; bảng → Places |
| Emma | 03-post-office.webp | Hòm thư → viết/gửi; bàn và kệ thư → bài mẫu |
| Ben | 04-workshop.webp | Gỗ, dụng cụ → sửa nhà; bàn thợ → nâng cấp |
| Clara | 05-bank.png | Quầy → gửi/rút; két → số dư |
| Tom | 06-garden-shed.png | Hạt/chậu/cây → Farm; dụng cụ → hướng dẫn |
| Noah | 07-pier-hut.webp | Cần câu → câu cá; thùng → xem thưởng |
| Mia | 08-market.png | Quầy → đơn hàng; sạp/kệ → Shop |

Chức năng viết thư vẫn yêu cầu học bài trước. Tương tác nội thất không bỏ qua điều kiện học hoặc khóa cấp.

## Tọa độ và hình ảnh

Khung game là 1280 × 720. Nội thất chiếm vùng 1280 × 600; 120 px còn lại dành cho thanh công cụ. Năm WebP 640 × 300 kế thừa là bản thu nhỏ của vùng nội thất 1920 × 900: khi hiển thị, tọa độ thiết kế gốc vẫn tương ứng hệ số 2/3. Ba PNG mới có kích thước 1672 × 941; renderer lấy 5/6 chiều cao để giữ bố cục tương đương và không kéo dãn đồ đạc vào thanh công cụ. Vùng tương tác và va chạm dùng tọa độ viewport, không nhân tỉ lệ thêm lần nữa.

Các nền mới được tạo/chỉnh bằng công cụ image generation tích hợp:

1. Ngân hàng: xóa Momo, bóng, nút ra ngoài và thanh công cụ khỏi ảnh gốc; giữ quầy, tủ khóa, két, cửa sổ và ánh sáng.
2. Nhà vườn: cùng thao tác làm sạch; giữ kệ hạt, bàn, dụng cụ và cây.
3. Chợ: dùng nhà vườn sạch làm tham chiếu kiến trúc/phong cách; thay nội thất bằng quầy bán hàng, rau củ, hạt giống và vải. Không có nhân vật hoặc nút vẽ sẵn.

Không dùng canvas công cộng Alpix để lưu tài sản riêng của game. Không cần thay composition Remotion hoặc thiết kế Pixelixe cho phần logic Godot này.

## Kiểm chứng

Lỗi trước sửa được ghi ở `logs/before-import.log` và `logs/red/test_journey_room_access.log`: hai ảnh lỗi giải mã, lỗi kiểu GDScript, bàn học không thể tiếp cận bằng E.

Lệnh chạy đầy đủ:

```bash
godot --headless --path . --editor --import --quit
python3 tools/run_tests.py --godot /path/to/Godot_v4.3-stable_linux.x86_64 --log-dir docs/rooms-step2/logs/full
```

Các test mới kiểm tra mọi điểm tiếp cận, click lên từng đồ vật, đi tới đúng nơi, mở đúng chức năng, E tương tác, quay về cửa, nói chuyện với NPC, chặn di chuyển khi có hộp thoại và khôi phục điều khiển ngoài trời. Các test trước đó kiểm tra vào/ra cả 8 phòng, lối đến Noah, giãn cách chữ và các chức năng học/nông trại.

Kết quả cuối ghi trong `RESULTS.md` và `logs/full/`.

## Giới hạn và kiểm tra tiếp

Chưa chạy cửa sổ Godot có renderer hoặc chơi thủ công trên Windows trong môi trường này. Headless xác nhận logic, hình học va chạm, tài nguyên giải mã và bố cục Control; không thay thế kiểm tra trực quan hoạt ảnh, font và mọi pixel ở các độ phân giải khác. Năm nền WebP kế thừa có độ phân giải thấp hơn ba PNG mới.

Bước 3 (hướng dẫn 10 trang), Bước 4 (slot lưu/migration) và Bước 5 (xuất bản chơi thử, kiểm tra tổng thể) chưa thuộc lần cập nhật này.
