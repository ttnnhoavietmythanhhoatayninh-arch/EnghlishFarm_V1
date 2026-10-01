# EnglishFarm — gói phác thảo V1

- `concepts/englishfarm-direction-v1.png`: Momo, 2 NPC, nông trại, nhà, chợ, HUD.
- `concepts/momo-poses-v1.png`: 12 tư thế trên nền trong suốt; 4 hướng, đi bộ và hoạt động.
- `models/`: đặc tả JSON cho nhân vật nhiều lớp, bản đồ, nội thất và HUD.
- `pixelixe/document.json`: liên kết mẫu giao diện đã tạo trong Pixelixe.
- `../art-preview/`: bộ trình bày Remotion, xuất ảnh tĩnh và xem chuyển cảnh.

## Trạng thái cần duyệt
Ảnh do AI tạo cho dự án; chưa đưa vào runtime. Đây là concept, KHÔNG phải atlas animation hoàn chỉnh. Hình tư thế còn khác nhẹ về tỷ lệ và điểm đặt chân; cần vẽ lại/chuẩn hóa khung 48×64, pivot, alpha viền, độ nhất quán trang phục trước khi tích hợp. Quy cách trong models là đích sản xuất, không mô tả kích thước PNG hiện có.

Ảnh người dùng gửi chỉ dùng tham khảo phong cách; không sao chép vào bộ tài nguyên để phát hành. Đồ họa cũ trong game/assets giữ nguyên nguồn dự án cũ; cần rà soát quyền sử dụng trước khi phát hành thương mại. Chưa có bằng chứng bảo đảm độc quyền đối với ảnh AI.

## Prompt và nguồn tạo
Công cụ tạo ảnh tích hợp; ngày 29/09/2026. Prompt 1: original EnglishFarm cozy pixel-art six-panel art direction sheet: orange/cream cat Momo, green scarf, teacher and merchant cats, central teal-roof cottage, vegetable beds, warm interior, market, Word Cards/Powers HUD; muted sage/cream/terracotta; original designs; concept only.
Prompt 2: transparent 4×3 character exploration sheet, Momo orange/cream cat green scarf/olive overalls; front/back/left/right, four walking poses, watering/reading/planting/celebrating; consistent identity; generous padding; no labels; concept only.

Alpix mở canvas công khai 256×256 dùng chung. Không vẽ đè lên tác phẩm cộng đồng để giả lập kho asset riêng. Không có tệp model AI hay mô hình huấn luyện riêng trong gói này.

## Cập nhật Town V2 (01/10/2026)
Quyết định mới thay thế NPC mèo trong concept đầu tiên: NPC là con người; Momo vẫn là mèo. `town-overview.png` là concept toàn thị trấn. `game/assets/town.png` là bản chỉnh bằng công cụ tạo ảnh: giữ vị trí công trình/đường/cầu, xóa nhân vật và tiêu đề, làm trống ruộng để đặt sprite runtime riêng. Concept NPC mèo giữ làm lịch sử, KHÔNG là thiết kế đang áp dụng.
