> Ghi chú01/10/2026: đây là hồ sơ nền V1. Town V2 đã bổ sung thị trấn/NPC người/đơn hàng/bản xuất Windows; tham chiếu town-v2/STATUS.md để tránh dùng trạng thái cũ.

# Cơ sở hoàn thiện hồ sơ EnglishFarm — 13 mục
Ngày 29/09/2026. Tài liệu làm việc; không phải hồ sơ chứng minh sản phẩm đã hoàn thành.

## 1. Bài toán thực tiễn
EnglishFarm hướng tới người học khó duy trì thói quen tiếp xúc tiếng Anh ngoài giờ học. Giả thuyết sản phẩm: nhiệm vụ đọc/viết gắn với chăm sóc nông trại có thể tăng động lực quay lại. Đây là giả thuyết cần kiểm chứng, chưa phải kết luận thực nghiệm. Bối cảnh chính sách người dùng cung cấp là Quyết định 2371/QĐ-TTg về đưa tiếng Anh thành ngôn ngữ thứ hai trong trường học giai đoạn 2025–2035, tầm nhìn 2045; khi nộp cần đối chiếu nguyên văn văn bản chính thức. Không suy ra chính sách là chứng cứ hiệu quả riêng của trò chơi.

## 2. Mục tiêu, phạm vi, đối tượng
Đối tượng theo phiếu trả lời: 8–30 tuổi, tự học tại nhà; cần tách trải nghiệm trẻ em và người trưởng thành khi thử nghiệm. Phạm vi chốt hiện tại: Reading, Writing, từ vựng, ngữ pháp; ba mức Easy A1–A2, Normal B1–B2, Hard C1. Các mức là mục tiêu biên soạn, chưa được thẩm định. Sản phẩm bổ trợ học tập; không thay thế chương trình học hay bảo đảm đạt chứng chỉ. Giáo viên có thể góp ý nội dung nhưng chưa xây dựng giao bài/lớp học.

## 3. Dữ liệu, nguồn và tính hợp lệ
Mã/asset nền được kế thừa từ repo Duckxyz06/English-Farm, nhánh codex/visual-farm-demo theo yêu cầu tiếp tục dự án. Chưa tìm thấy tệp LICENSE ở gốc bản tải về; cần kiểm kê quyền asset và mã trước công bố thương mại. Nội dung learning_v1.json tự soạn trong phiên: 9 từ, 3 bài đọc, 9 câu đọc, 3 câu ngữ pháp, 3 đề viết. Ảnh mới do AI tạo, có prompt ghi trong art/README.md; không phải mô hình tự huấn luyện. Ảnh tham khảo người dùng không được đóng gói lại. Save chỉ chứa tiến trình, không yêu cầu tên, email hay giọng nói. Bản nháp thư chỉ ở bộ nhớ. Không có tập dữ liệu người học thật được thu thập trong phiên.

## 4. Tổ chức và xử lý dữ liệu
Dữ liệu bài học phân theo difficulty; mỗi từ gồm word/definition/example; câu hỏi gồm prompt/answers; grammar có đáp án và giải thích. Khi so sánh câu trả lời: bỏ khoảng trắng đầu/cuối, chuyển chữ thường; chấp nhận danh sách đáp án ngắn. Chưa có kiểm tra ngữ nghĩa câu trả lời mở nên có thể từ chối một diễn đạt đúng. Cần quy trình giáo viên kiểm duyệt: biên soạn → kiểm nguồn → gán CEFR/chủ đề/kỹ năng → kiểm đáp án → thử người học → phát hành có phiên bản. JSON model asset ghi rõ concept hay đặc tả chưa triển khai.

## 5. Thuật toán và AI
Hiện game dùng luật xác định cho thưởng, lịch ôn 24h, cây trồng, kiểm đáp án; không dùng mô hình AI lúc chơi. Mã và ảnh được hỗ trợ tạo bằng công cụ AI trong quá trình phát triển. Remotion là công cụ trình bày ảnh bằng React, Pixelixe là công cụ thiết kế giao diện; không gọi chúng là mô hình AI được đội huấn luyện. Alpix là canvas công cộng, không dùng làm kho riêng. Bảng kiểm viết không phải AI và không quy đổi thành band IELTS/VSTEP.

## 6. Huấn luyện/tích hợp mô hình
Chưa huấn luyện hoặc fine-tune mô hình. Nếu bổ sung chấm viết: đầu vào gồm đề, bài viết, rubric, mục tiêu cấp độ; đầu ra theo schema gồm nhận xét, ví dụ sửa, độ chắc chắn. Cần kiểm thử bộ bài có giáo viên chấm, giới hạn độ dài, lọc dữ liệu cá nhân và kiểm đầu ra trước khi áp dụng thưởng. Không nhúng API key vào game. Do ngân sách hiện bằng 0, ưu tiên bảng kiểm và rubric ngoại tuyến trước.

## 7. Tiêu chí đánh giá
Kỹ thuật: chống thưởng lặp, lưu/khôi phục, timer, cooldown, điều hướng. Học tập dự kiến: bài kiểm tra trước/sau cùng độ khó, nhớ từ sau 7/30 ngày, chất lượng thư theo rubric do người đánh giá, tỷ lệ hoàn thành nhiệm vụ. Trải nghiệm: D1/D7/D30 nếu có đồng thuận thu thập, phút học có ý nghĩa, mức khó chịu vì cây héo, khả năng dùng chữ lớn. Không đồng nhất giờ chơi với tiến bộ tiếng Anh. Cần công bố cỡ mẫu, thời gian, tiêu chí loại dữ liệu và hạn chế.

## 8. Kết quả và khả năng mở rộng
Đã có kiểm thử tự động headless bằng Godot 4.3 cho trạng thái học, tích hợp UI và bộ kiểm thử demo cũ; xem STATUS.md. Chưa có thử nghiệm người học, kiểm thử máy Windows thật, Android/iOS hoặc đo tác động học tập. Ưu điểm dự kiến: ngoại tuyến, phần thưởng liên hệ trực tiếp học tập, chi phí vận hành thấp. Hạn chế: nội dung ít, luật chấm đơn giản, đồ họa mới chưa chuẩn atlas, đồng hồ thiết bị có thể thay đổi, tài nguyên nền chưa kiểm đủ quyền. Mở rộng theo từng gói nội dung và schema phiên bản.

## 9. So sánh và đóng góp
Đường cơ sở đề xuất: cùng nội dung dưới dạng bài tập không game. So sánh với bản có game và bản có/không thưởng để tách tác động nội dung, phản hồi và game. Cảm hứng Stardew Valley/Hay Day là vòng lặp chăm sóc/phát triển, không phải quyền sao chép tài sản. Điểm khác biệt dự kiến là dùng năng lực ngôn ngữ để mở khóa hoạt động. Chưa có nghiên cứu đối chứng hay chứng cứ vượt trội sản phẩm khác.

## 10. Kiến trúc và triển khai
Godot LearningV1 scene → learning_main.gd (UI/điều phối) → learning_state.gd (luật/tiến trình) → JSON save cục bộ. data/learning_v1.json cung cấp nội dung. Momo/Navigation/Art kế thừa demo cũ. Art concept tách runtime. art-preview là project Remotion riêng; không phải giao diện web của game. CI có import/test/capture/export Windows. Chưa triển khai CI trên kho đích vì quyền kết nối chỉ đọc. Android cần SDK/export preset; iOS cần môi trường ký và build phù hợp. Không có máy chủ hay cơ sở dữ liệu đám mây.

## 11. Rủi ro và an toàn
Rủi ro chính: nội dung sai, lệch cấp độ, mất save, lạm dụng đồng hồ, áp lực mất cây, quyền asset, trẻ em chia sẻ thông tin trong bài viết. Hiện không gửi bài viết ra ngoài, không microphone, không tài khoản, không quảng cáo hoặc mua vật phẩm. Save dùng ghi tạm rồi đổi tên và kiểm cấu trúc cơ bản, chưa có backup phục hồi nhiều phiên. Có nhắc nghỉ sau 180 phút; cần thử xem ngưỡng này phù hợp tuổi, bổ sung lựa chọn chăm sóc nhẹ nhàng. Nếu thêm AI/cloud: cần cơ chế đồng thuận, tối thiểu hóa dữ liệu, xóa dữ liệu, giới hạn prompt injection và đầu ra không phù hợp. Chưa tuyên bố tuân thủ pháp lý hoàn chỉnh khi chưa được rà soát.

## 12. Lộ trình
P0: duyệt phong cách; chuẩn hóa animation; thẩm định nội dung; đồng bộ ruộng lên map; nhà trung tâm/collision; backup save; thử Windows với 5–10 người tự nguyện có thủ tục phù hợp độ tuổi. P1: cây 24h, quota theo cấp, từ điển click, gợi ý 50/50, thư/order nhiều bước, tùy biến nhân vật; test hiệu quả học nhỏ. P2: Android trước, iOS khi có điều kiện; chấm viết AI khi ngân sách và đánh giá chất lượng cho phép. Chỉ mở rộng khi tiêu chí hoàn thành từng giai đoạn đạt, không đặt số liệu kết quả giả định.

## 13. Lịch sử và minh chứng
Bộ ZIP gồm mã, dữ liệu, concept, prompt tóm tắt, model JSON, Remotion, Pixelixe, test và trạng thái. Chưa có Google Drive được cung cấp; không bịa liên kết hoặc tự mở quyền công khai. Khi nộp: chủ dự án tạo thư mục minh chứng, tải bản được phép công bố, giữ lịch sử phiên bản và ảnh chạy thật, kiểm quyền xem bằng tài khoản khác. Không gọi concept là ảnh chạy thật hoặc dùng log test làm chứng cứ cải thiện trình độ.
