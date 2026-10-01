# EnglishFarm V4 runtime asset manifest

Nguồn chuẩn: `EnglishFarm_Pixel_Guide_Rooms_V4/EnglishFarm_Pixel_V4/`.

## Phòng

| Runtime ID | Nguồn V4 | Runtime layer | Cách dùng |
|---|---|---|---|
| home | Rooms/01-home.png | game/assets/v4/rooms/01-home-upper.webp | Nhà chính |
| lily | Rooms/02-library.png | game/assets/v4/rooms/02-library-upper.webp | Thư viện |
| emma | Rooms/03-post-office.png | game/assets/v4/rooms/03-post-office-upper.webp | Bưu điện |
| ben | Rooms/04-workshop.png | game/assets/v4/rooms/04-workshop-upper.webp | Xưởng |
| clara | Rooms/05-bank.png | game/assets/v4/rooms/05-bank-upper.webp | Ngân hàng |
| tom | Rooms/06-garden-shed.png | game/assets/v4/rooms/06-garden-shed-upper.webp | Nhà vườn |
| noah | Rooms/07-pier-hut.png | game/assets/v4/rooms/07-pier-hut-upper.webp | Bến tàu |

Mia/Market không ánh xạ vào bảy phòng trên. `Reference/market-reference.jpeg` chỉ là ảnh tham chiếu.

Ảnh phòng V4 là màn hình hoàn chỉnh có Momo, nút Ra ngoài và thanh chức năng đã dính vào ảnh. Runtime **không dùng nguyên ảnh làm nền**. Pipeline lấy vùng trên an toàn `1920 x 570`, thu về `1280 x 380`, rồi WebP hóa. Vùng cắt này giữ tường, cửa sổ và nội thất riêng của phòng nhưng loại Momo/nút giả/thanh giả. Phần sàn dưới, Momo thật, hotspot, collision, nút Ra ngoài và toolbar là node runtime.

## Tutorial

| Trang | Nguồn | Runtime |
|---|---|---|
| 00 | Guides/00-start.png | game/assets/v4/guides/00-start.webp |
| 01 | Guides/01-move.png | game/assets/v4/guides/01-move.webp |
| 02 | Guides/02-learn.png | game/assets/v4/guides/02-learn.webp |
| 03 | Guides/03-seeds.png | game/assets/v4/guides/03-seeds.webp |
| 04 | Guides/04-farm.png | game/assets/v4/guides/04-farm.webp |
| 05 | Guides/05-tasks.png | game/assets/v4/guides/05-tasks.webp |
| 06 | Guides/06-rewards.png | game/assets/v4/guides/06-rewards.webp |
| 07 | Guides/07-delivery-letters.png | game/assets/v4/guides/07-delivery-letters.webp |
| 08 | Guides/08-places.png | game/assets/v4/guides/08-places.webp |
| 09 | Guides/09-help.png | game/assets/v4/guides/09-help.webp |
| farm illustration | Guides/farming-illustration.png | game/assets/v4/guides/farming-illustration.webp |

Các nút vẽ trong PNG không nhận click. `journey_main.gd` đặt control thật bên ngoài vùng nội dung ảnh. Nếu toàn bộ 10 ảnh V4 chưa có trong `res://`, game tự rơi về tutorial chữ cũ để project vẫn mở/test được; bản bàn giao đầy đủ phải chứa các file runtime ở bảng trên.

## Tài nguyên chỉ tham khảo

- Rooms/00-room-overview.png: bảng xem nhanh, không dùng làm nền phòng.
- Source/Remotion/art-preview/public/v4/town-starter.png: tham khảo thị trấn; không thay bản đồ đang chạy.
- Momo/concept cũ: tham khảo; không thay sprite sheet runtime.
