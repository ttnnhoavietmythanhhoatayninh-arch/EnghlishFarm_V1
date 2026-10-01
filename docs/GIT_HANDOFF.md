# Chuyển toàn bộ source lên GitHub
Kho đích: https://github.com/ttnnhoavietmythanhhoatayninh-arch/EnghlishFarm_V1
Ngày01/10/2026, thông tin repo báo push=true nhưng create_file trả403 Resource not accessible by integration. Đây là quyền ứng dụng, không phải thiếu sự đồng ý của chủ kho. Chưa có tệp được ghi lên GitHub.

Cách tiếp tục: kết nối GitHub cần được cấp quyền ghi nội dung trên đúng repo. Không gửi token/mật khẩu trong chat.

Hoặc dùng Git đã đăng nhập trên Windows của bạn: giải nén source, mở PowerShell trong thư mục EnglishFarm_V1, chạy `./publish-github.ps1`. Script chỉ dùng cho kho đích còn trống; nếu có nội dung, dừng để tránh ghi đè. Chỉ chạy script sau khi bạn đọc nội dung của nó. Script không sửa policy PowerShell hoặc yêu cầu token.

EXE/PCK nên phân phối qua Releases hoặc artifact của Actions, không commit vào source. Workflow tự build Windows và test khi source được push main. ZIP Windows đã có riêng trong bàn giao.
