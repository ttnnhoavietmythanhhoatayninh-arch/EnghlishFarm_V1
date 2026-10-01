# V4 binary assets

Thư mục này chứa các lớp runtime được tạo từ bộ V4 do chủ dự án cung cấp.

- `rooms/*-upper.webp`: chỉ vùng trên của phòng; không chứa Momo/nút Ra ngoài/toolbar giả.
- `guides/*.webp`: 10 trang hướng dẫn ở 1280 x 720 và minh họa Farm.
- Mã nguồn vẫn có fallback procedural để CI có thể chạy khi binary V4 chưa được đặt vào checkout.

Tạo lại asset bằng `tools/build_v4_runtime_assets.py <EnglishFarm_Pixel_V4>`.
