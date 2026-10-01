Bản V1 đã được tiếp tục thành Town V2. Trạng thái hiện tại: [town-v2/STATUS.md](town-v2/STATUS.md).

# Trạng thái bàn giao V1

## Hoàn thành và đã kiểm tra
- Khôi phục source archive nhánh codex/visual-farm-demo; giữ demo cũ để đối chiếu.
- Màn chính mới LearningV1, state riêng, nội dung mẫu 3 mức, Word Cards/Powers, lịch ôn, seed unlock, 6 ô ruộng, bảng kiểm viết, settings.
- Godot 4.3 headless import không lỗi script.
- test_learning.gd: Learning state failures: 0.
- test_learning_ui.gd: Learning UI integration: passed.
- test_game.gd của source cũ: ENGLISH_FARM_TESTS_PASSED.
- 2 PNG concept mới, JSON thiết kế, Pixelixe blueprint, project Remotion.

## Chưa hoàn thành / không được diễn giải thành đã xong
- Chưa push GitHub: quyền kết nối push=false.
- Chưa có bộ cài Windows mới hoặc Android/iOS trong ZIP; chạy source bằng Godot. Workflow xuất Windows đã chuẩn bị, chưa chạy ở kho đích.
- Chưa kiểm tra giao diện Godot bằng màn hình đồ họa trong phiên này. Headless không thay cho kiểm thử hình ảnh.
- Concept chưa được chủ dự án duyệt và chưa tích hợp runtime. Nhân vật cần chuẩn hóa frame/pivot trước animation.
- Không có thử nghiệm người học, AI chấm viết hoặc số liệu hiệu quả học tập.
- Các kế hoạch trong art/models chưa phải chức năng runtime. Dự án chưa có trained image model/LoRA.

## Ghi chú tiến độ
File trạng thái này là nguồn chính cho V1; tài liệu docs/legacy phản ánh các bản cũ.

## Remotion
`npm install` thành công, `npm run typecheck` thành công; Remotion bundle đạt 100%. Xuất still chưa hoàn thành do môi trường trả lỗi `uv_interface_addresses` khi mở máy chủ render. Không sửa/bỏ qua giới hạn môi trường. PNG trong art/concepts là ảnh tạo trực tiếp, không phải ảnh render Remotion. Có package-lock.json để tái lập trên máy phát triển.

## Git cục bộ
Đã khởi tạo repository và commit bản bàn giao tại máy làm việc, gắn remote kho đích. ZIP mã nguồn không chứa thư mục .git; làm theo GIT_HANDOFF.md để tạo commit/push trên máy có quyền ghi.
