# EnglishFarm Journey V3

Godot 4.3, bản thử Windows. Scene chính: `game/scenes/Journey.tscn`. Momo là mèo, NPC là người. Đọc `docs/PLAY_DEMO_VI.txt` để chơi và `docs/journey-v3/STATUS.md` để xem phạm vi kiểm chứng.

## Thay đổi V3
- Chọn Easy/Normal/Hard trước lần chơi đầu; hướng dẫn 6 trang, nút ?/F1 và × đóng.
- Học trước quiz: từ vựng có IPA, trọng âm, nghĩa Việt, giải thích Anh, cách dùng/ví dụ; bài ngữ pháp, đọc, viết và từ chỉ địa điểm.
- Các nút chức năng tách riêng; hộp thoại nền giấy sáng; minimap nhỏ góc phải.
- Khởi đầu nhà gỗ đơn giản, 3 ô ruộng. Mỗi cấp hoàn thành 3 nhiệm vụ; mở khu vực theo cấp, nâng nhà, mua mở rộng và trang phục.
- 7 NPC có tên/vai trò/quan hệ; phòng tương tác, xe giao hàng chạy, ngân hàng gửi/rút và minigame câu cá.
- Lưu ngoại tuyến vào `user://englishfarm_journey_v3.json`, tách khỏi V2.

## Chạy và xuất
Import `project.godot` bằng Godot 4.3, nhấn F6 tại Journey hoặc F5 chạy dự án. Với gói Windows, giải nén rồi chạy EXE cạnh PCK.

```sh
godot --headless --path . --editor --quit
godot --headless --path . --script tests/test_journey.gd
godot --headless --path . --script tests/test_journey_ui.gd
godot --headless --path . --script tests/test_journey_layout.gd
godot --headless --path . --export-release "Windows Desktop" build/windows/EnglishFarm.exe
```

## Cấu trúc
`game/scripts/journey_*`: giao diện, tiến trình, điều hướng, phòng, xe và minimap; kế thừa `town_*`/`learning_*`. `data/curriculum_v3.json`: nội dung dạy. `game/assets`: tài nguyên runtime. `tests`: kiểm thử và capture. `art`/`art-preview`: bộ art và Remotion trước đây. Các scene cũ giữ để đối chiếu, không là màn mặc định.

## Giới hạn bản thử
9 từ học chính, 3 đơn vị ngữ pháp, 3 bài đọc, các mẫu viết và 8 từ địa điểm; không phải giáo trình hoàn chỉnh. Chưa có AI chấm viết hoặc bài nghe/nói. Phát âm từ tùy giọng TTS hệ điều hành. Nội thất là màn tương tác bằng nút; 7 NPC dùng lại 3 bộ sprite người. Bản đồ nền ảnh có lớp tương tác, chưa là tilemap. Có 4 cấp nhiệm vụ, đạt cấp 5 kết thúc chương. Chưa có tài khoản mạng, lịch sinh hoạt NPC hoặc mobile.

## GitHub
Kho đích: https://github.com/ttnnhoavietmythanhhoatayninh-arch/EnghlishFarm_V1
Lần ghi trước bị 403 `Resource not accessible by integration`; chưa đẩy được mã nguồn. `publish-github.ps1` hỗ trợ người có Git và quyền ghi hợp lệ đưa nguồn vào kho trống, không force push. Workflow chạy test và xuất Windows khi nguồn đã lên GitHub.

Nguồn kế thừa: Duckxyz06/English-Farm, nhánh codex/visual-farm-demo. Hồ sơ V1/V2 được giữ làm lịch sử; hướng dẫn V3 này là bản hiện hành. Chưa áp giấy phép mới cho tài nguyên kế thừa chưa rõ quyền.
