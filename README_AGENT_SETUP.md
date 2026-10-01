# Cài EnglishFarm AutoDev Agent

## 1. Copy bộ kit vào root repository

Sao chép các thư mục/file:
- `AGENTS.md`
- `.github/workflows/englishfarm-autodev.yml`
- `agent/`
- `scripts/agent_verify.sh`
- `assets/npc-update/`

Không ghi đè source game ngoài các file trên.

## 2. Thêm OpenAI API key vào GitHub

Repository -> Settings -> Secrets and variables -> Actions -> New repository secret

Tên:
`OPENAI_API_KEY`

Giá trị:
API key của project OpenAI mà bạn dùng cho agent.

Không commit API key vào source.

## 3. Cho GitHub Actions quyền ghi

Repository -> Settings -> Actions -> General -> Workflow permissions

Chọn:
`Read and write permissions`

Cho phép GitHub Actions tạo/approve pull request nếu repository yêu cầu.

## 4. Cách ra lệnh

### Cách A — chạy tay
Actions -> `EnglishFarm Autonomous Developer` -> Run workflow
Nhập task, ví dụ:

`Sửa toàn bộ vùng Momo đi xuyên hàng rào và sạp chợ. Viết regression test trước, giữ nguyên save cũ.`

### Cách B — Issue
Tạo GitHub Issue, mô tả yêu cầu và thêm label:
`agent-run`

Agent sẽ lấy Issue làm task.

### Cách C — tự phát triển
Workflow có schedule mỗi ngày.
Nếu không có task rõ ràng, agent lấy mục chưa hoàn thành cao nhất trong `agent/ROADMAP.md`.

## 5. Cơ chế tự sửa
- Codex sửa source.
- `scripts/agent_verify.sh` chạy Godot tests bằng Docker.
- Nếu fail: log được đưa lại cho agent để repair.
- Agent có thêm tối đa 2 vòng repair.
- Chỉ sau final verification xanh mới commit/push.
- Tạo PR.
- Auto merge khi được bật.

## 6. Điều chỉnh mức tự động
Muốn an toàn hơn:
- xóa `schedule:` để agent chỉ chạy khi bạn yêu cầu;
- đổi `auto_merge` mặc định thành false.

Muốn tự động hoàn toàn:
- giữ schedule;
- giữ auto_merge;
- bảo đảm branch protection yêu cầu CI xanh.

## 7. Lưu ý
API usage có chi phí riêng.
Nên giữ branch protection + CI làm cổng cuối, kể cả khi bật auto-merge.
