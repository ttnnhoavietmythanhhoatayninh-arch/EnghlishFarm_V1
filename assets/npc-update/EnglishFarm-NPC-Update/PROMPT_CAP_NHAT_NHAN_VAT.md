# PROMPT — Cập nhật 7 NPC khác nhau + tên nổi trên đầu (EnglishFarm Journey)

Bạn là lập trình viên Godot 4.3 (GDScript). Hãy cập nhật dự án **EnglishFarm Journey** theo yêu cầu sau.
Gói tài nguyên nằm trong thư mục `EnglishFarm-NPC-Update/` (xem `npc_data.json`).

## 1. Bối cảnh
- Hiện game chỉ có 3 bộ sprite NPC (`res://game/assets/npcs.png`, 1536×1024, lưới 3 cột × 2 hàng, ô 512×512, nền magenta, xử lý bằng `res://game/assets/color_key.gdshader`) nên 7 NPC người dùng lại sprite của nhau.
- 7 NPC: **Noah, Lily, Ben, Mia, Emma, Tom, Clara**. Momo là mèo, giữ nguyên.
- Tên NPC hiện chỉ xuất hiện trong khung hội thoại / textbox.

## 2. Yêu cầu
1. **Mỗi NPC một sprite riêng, khác nhau hoàn toàn.** Dùng `characters/npc_<id>.png` (512×512, nền trong suốt, nhân vật cao 400 px, chân ở y=502, căn giữa ngang). Khuyến nghị load từng texture theo `npc_data.json` thay vì cắt atlas. Nếu bắt buộc dùng atlas, dùng `atlas/npcs_atlas_magenta_4x2_2048x1024.png` (4 cột × 2 hàng, ô 512×512, `index = row*4 + col`, ô cuối trống) và sửa `hframes/vframes` hoặc region tương ứng.
2. **Tên hiển thị nổi ngay trên đầu NPC, không nằm trong textbox/khung.** Dùng `godot/npc_name_tag.gd` (Label + outline), hoặc ảnh `nametags/nametag_<id>.png` nếu không muốn dùng font.
3. **Dễ nhìn nhất cho game:**
   - Chữ in đậm, cỡ ≥ 14 px (mặc định 18 px) trên màn hình; viền tối `#2B1B12` dày 4–5 px; bóng nhẹ; KHÔNG dùng nền hộp/khung.
   - Mỗi NPC một màu chữ sáng (xem `name_color` trong JSON) để phân biệt nhanh.
   - Căn giữa theo chiều ngang, đặt cách đỉnh đầu ~6 px, `z_index` cao để không bị cây/nhà che.
   - Giữ cỡ chữ cố định khi camera zoom hoặc NPC bị scale (`keep_screen_size = true`).
   - Không đè lên nhau: nếu hai tên chồng nhau thì đẩy tên của NPC phía sau lên 12–16 px.
   - Ẩn tên khi NPC đang mở hội thoại (hoặc giữ, nhưng không được trùng với tên trong khung thoại).
4. Giữ nguyên toàn bộ logic nhiệm vụ, click NPC đi tới nói chuyện, phím E, hội thoại, lưu game.

## 3. Cách làm
1. Tìm nơi tạo/vẽ NPC (gợi ý: `town_main.gd`, `journey_main.gd`, `journey_room.gd`, `art.gd`, `TeacherNPC.tscn`) và nơi đang ánh xạ NPC → sprite 3 bộ.
2. Thay bằng bảng ánh xạ id → texture + màu tên (lấy từ `npc_data.json`).
3. Thêm `NpcNameTag` làm node con của mỗi NPC; đặt `head_y = -(400 * sprite_scale + 6)` theo scale thực tế của sprite.
4. Đặt Texture Filter đúng với phong cách hiện tại (pixel art thường dùng Nearest) và kiểm tra không còn viền hồng nếu dùng atlas magenta.
5. Không đổi sprite của Momo (mèo), map, vật phẩm.

## 4. Nghiệm thu
- [ ] 7 NPC nhìn khác hẳn nhau, không NPC nào dùng lại sprite NPC khác.
- [ ] Tên nằm trên đầu từng NPC, đọc rõ trên cỏ, đường, trong nhà.
- [ ] Tên không nằm trong textbox; không bị che bởi cây/nhà/UI.
- [ ] Zoom camera và đổi cỡ chữ trong Settings không làm tên méo/vỡ/quá nhỏ.
- [ ] Click NPC → nói chuyện, E → nói chuyện, nhiệm vụ cấp 1–5 vẫn chạy.
- [ ] Không lỗi/warning mới trong Output.

## 5. Giả định cần xác nhận (sửa trong npc_data.json nếu sai)
Noah = câu cá · Lily = cô giáo · Ben = thợ mộc · Mia = đặt cà rốt · Emma = thư · Tom = nông dân · Clara = ngân hàng cards.
