# Bước 1: nền tảng Journey

- Nền mã: main 23bfa54. Nhánh codex/journey-v4-foundation. Giữ Seasons prototype ở nhánh riêng.
- Đã tái hiện lỗi: nút ra ngoài có đáy624, vượt giới hạn620; harness mới báoFAIL và exit1.
- safe_walkable_near tìm theo vòng5/15/30/50 rồi lưới dự phòng220px cho cửa cũ; có warning và trả điểm gốc khi không tìm được. leave_room kiểm tra lại và rơi về NPC/nhà an toàn.
- has_walkable_step hỗ trợ hướng đích; kiểm tra clearance12px và đoạn đi24px.
- Cửa Mia chuyển về940,590 (tọa độ ảnh), NPC920,580. Điểm thoát chuẩn door*2+(0,110), an toàn hóa trước đặt Momo.
- Nút Ra ngoài y540, không ký tự mũi tên; Momo được mở khóa ngay, khôi phục camera/parent.
- 13 nhóm vật cản thêm theo ảnh nguồn1536×1024. Giữ lối phía Đông Bưu điện tớiNoah. Mask chưa áp dụng: navigation polygon+obstacles là nguồn chính xác hiện tại.
- Test hỗ trợ failure sticky, trả exit1. Runner đọcstream và dừng ngay lỗi đầu tiên, timeout/thiếuPASSED cũng fail. Fixturefail và7self-test runner được kiểm chứng.
- Test layout ghi/xóa filetest riêng, không dùng saveV3 người chơi. production save_path vẫn làuser://englishfarm_journey_v3.json.
- Cổng: test_journey_rooms, test_journey_layout, test_journey_spacing đều đạt. 11suite hồi quy đạt, gồmtest_journey_obstacles mới. Log trongthư mục này.

## Walkmask nếu phát triển tiếp
Không nạp walkmask ở bước này. Khi áp dụng: ảnh1536×1024, trắng cho đường và sân, đen cho nhà/rào/bụi/nước; giữ cửa/cầu và lối sangNoah. Tọa độworld chia2 trước tra pixel; kiểm tra cả footprint nhân vật và toànđoạn bước đi. Nạp mask trướcbuild_grid, cập nhật cảAStar vàcan_travel. Kiểm tra lại8cửa và đường tớiNoah trước xuất. Không chỉ lấy nguyênpolygon cũ làm mask rồi gọi là đã sửa hìnhhọc.

## Chưa xác nhận
Chưa chạy thao tác thủ công trênWindows/renderer. Các kiểm tra hiện tại chạyGodot4.3 headless; kết quả không đồngnghĩa mọi pixel vật cản trênbảnđồ đã được ràsoát bằngmắt.
