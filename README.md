# Đồ án NLP: Tìm kiếm ảnh ký tự Hán-Nôm tương đồng

[![Python](https://img.shields.io/badge/Python-3.10%2B-3776AB)](#)
[![PyTorch](https://img.shields.io/badge/PyTorch-2.6-EE4C2C)](#)
[![Chinese-CLIP](https://img.shields.io/badge/Chinese--CLIP-Fine--tuned-blue)](#)
[![FAISS](https://img.shields.io/badge/Search-FAISS-005571)](#)
[![Hugging Face](https://img.shields.io/badge/Model-Hugging_Face-yellow)](https://huggingface.co/vohoangkh4ng/chinese-clip-ft-sinonom)
[![License](https://img.shields.io/badge/License-MIT-green)](#)

- **Repository:** <https://github.com/vo-hoang-kh4ng/comparing-character-glyph-images-Sino-N-m>
- **Mô hình đã huấn luyện:** <https://huggingface.co/vohoangkh4ng/chinese-clip-ft-sinonom>
- **Báo cáo:** [`report/paper.pdf`](report/paper.pdf) — 12 trang, định dạng bài hội nghị.

Dự án xây dựng hệ thống tìm kiếm ký tự Hán-Nôm tương đồng dựa trên hình dạng glyph. Với một ảnh ký tự Hán-Nôm đầu vào, hệ thống trích xuất embedding thị giác và tìm các ký tự có hình dạng gần nhất trong corpus gồm **26.044 ảnh ký tự**.

Hệ thống hỗ trợ hai tình huống sử dụng:

- **Phần 1 — Tìm kiếm trên toàn corpus:** tìm các ký tự tương đồng nhất khi chưa biết ký tự truy vấn là gì.
- **Phần 2 — Xếp hạng trong nhóm cùng âm Quốc Ngữ:** xếp hạng các ký tự có cùng âm đọc Quốc Ngữ khi đã biết âm đọc của ký tự truy vấn.

## Kết quả chính

Kết quả được đo trên **59 ảnh scan viết tay thật**. Không có bất kỳ pixel nào trong tập này được sử dụng cho quá trình huấn luyện.

| Phương pháp | Phần 1 — `hit@1` trên 26.044 ký tự | Phần 2 — đúng top-1 trong nhóm | `radical@k` toàn corpus |
|---|---:|---:|---:|
| ResNet18 (bản gốc) | — | 0.4407 | 0.2316 |
| Chinese-CLIP zero-shot | 0.0847 | 0.4746 | 0.5361 |
| **Chinese-CLIP fine-tuned (đề xuất)** | **0.5932** | **0.8136** | — |

Mô hình fine-tuned cải thiện `hit@1` từ **0.0847 lên 0.5932** ở Phần 1 và tăng độ chính xác top-1 từ **0.4746 lên 0.8136** ở Phần 2.

## Tái lập kết quả

Phần này hướng dẫn tái lập toàn bộ kết quả trong báo cáo từ một bản clone sạch. Hãy đọc mục [Chuẩn bị môi trường và dữ liệu](#chuẩn-bị-môi-trường-và-dữ-liệu) trước khi chạy bất kỳ lệnh nào.

### Chuẩn bị môi trường và dữ liệu

#### Dữ liệu có sẵn trong repository

Hai thành phần quan trọng nhất đã được đưa sẵn vào repository:

| Thành phần | Đường dẫn | Vai trò |
|---|---|---|
| 59 ảnh scan viết tay | `test_images/` | Tập đánh giá thật duy nhất của đồ án |
| Nhãn Phần 2 gán tay | `output/label_sheets/label_template.csv` | Nhãn dùng để đánh giá Phần 2 |

**Lưu ý:** File `output/label_sheets/label_template.csv` được gán nhãn thủ công. Việc chạy lại mã nguồn **không** tạo lại được file này. Không xoá hoặc ghi đè file này.

#### Dữ liệu cần đặt vào repository

Dữ liệu đề bài phát không được đưa trực tiếp vào repository. Cần đặt các thành phần sau vào thư mục gốc của dự án:

| Thành phần | Vị trí đặt | Bắt buộc cho |
|---|---|---|
| `images/` — giải nén từ `images.zip`, gồm 26.044 file `<UNICODE>.jpg` | `./images/` | Mọi thí nghiệm |
| `final_characteristics-v2.xlsx` | `./` | Mọi thí nghiệm |
| `QuocNgu_SinoNom_Dic.xlsx` | `./` | Phần 2 |

Bản sao dự phòng của dữ liệu có thể tải tại:

<https://drive.google.com/drive/folders/12kfJjiM866taJS_-QhOS30TmRi1000Bt>

#### Yêu cầu phần cứng

- Các bước 1–3 có thể chạy trên CPU.
- Bước fine-tune cần GPU có ít nhất **6 GB VRAM**. Trong thực nghiệm, mức sử dụng VRAM cao nhất khoảng **3.7 GB**.
- Nếu không có GPU, có thể bỏ qua bước fine-tune và tải trực tiếp checkpoint đã công bố từ Hugging Face.

### Cài đặt

```bash
git clone https://github.com/vo-hoang-kh4ng/comparing-character-glyph-images-Sino-N-m.git
cd comparing-character-glyph-images-Sino-N-m

python3 -m venv .venv
.venv/bin/pip install -r requirements.txt

.venv/bin/python -m pytest -q
# Kỳ vọng: 66 passed
```

Toàn bộ lệnh bên dưới sử dụng `.venv/bin/python` và phải được chạy từ **thư mục gốc của repository**. Các script sẽ truy cập các thư mục tương đối như `./images`, `./output`, `./test_images` và `./fonts`.

Ở lần chạy đầu tiên, backend Hugging Face sẽ tự động tải trọng số mô hình vào `~/.cache/huggingface`, bao gồm khoảng 600 MB cho Chinese-CLIP và 350 MB cho DINOv2.

Nếu máy không có kết nối Internet, hãy chuẩn bị sẵn Hugging Face cache hoặc cấu hình biến môi trường `HF_HOME`.

<details>
<summary>Cài đặt trên máy chủ dùng chung đã có PyTorch</summary>

Nếu máy đã cài sẵn PyTorch và không được phép thay đổi môi trường hệ thống, có thể tạo virtual environment kế thừa site-packages:

```bash
python3 -m venv --system-site-packages .venv
.venv/bin/pip install "torchvision==0.21.0" faiss-cpu opencv-python-headless
```

Lưu ý rằng `torchvision` phải tương thích với phiên bản PyTorch đã cài. Với PyTorch 2.6.0, sử dụng `torchvision==0.21.0`.

Sử dụng `opencv-python-headless` khi hệ thống không có thư viện `libGL.so.1`.

</details>

## Đánh giá proxy trên toàn corpus

Bước này tái lập kết quả trong **Bảng IV** của báo cáo.

```bash
PY=.venv/bin/python

for backend in resnet18 resnet18-gray chinese-clip dinov2; do
  $PY search_all_chars_in_corpus.py \
    --backend $backend \
    --device cuda \
    --batch-size 32
done

$PY search_all_chars_in_corpus.py \
  --backend chinese-clip-large \
  --device cuda \
  --batch-size 32 \
  --dtype fp16

$PY search_all_chars_in_corpus.py \
  --backend chinese-clip-huge \
  --device cuda \
  --batch-size 32 \
  --dtype fp16

$PY benchmark_extractors.py
$PY analyze_metric_ceiling.py
$PY benchmark_search.py
```

Nếu chạy trên CPU, bỏ tham số `--device cuda`. Với các backend ViT, CPU sẽ chậm hơn đáng kể. Có thể thêm `--limit 500` để kiểm thử nhanh.

Embedding được cache tại:

```text
output/embeddings_<backend>.npz
```

### Kết quả kỳ vọng

Chỉ số `radical@k`, với `k = 20`:

| Backend | `radical@k` |
|---|---:|
| `resnet18` | 0.2316 |
| `resnet18-gray` | 0.2202 |
| `chinese-clip` | 0.4843 |
| `chinese-clip-large` | **0.5361** |
| `chinese-clip-huge` | 0.5147 |
| `dinov2` | 0.3081 |

## Đánh giá zero-shot trên scan thật

Bước này tái lập kết quả trong **Bảng V** và **Bảng VI** của báo cáo.

### Phần 1 — Tìm kiếm trên toàn corpus

```bash
$PY evaluate_test_images.py \
  --backend chinese-clip-large \
  --dtype fp16 \
  --device cuda
```

Kết quả kỳ vọng:

| Chỉ số | Giá trị |
|---|---:|
| `hit@1` | 5/59 = 0.0847 |
| `hit@20` | 0.2034 |
| `MRR` | 0.1143 |

### Phần 2 — Xếp hạng trong nhóm cùng âm Quốc Ngữ

```bash
$PY evaluate_test_images.py \
  --part 2 \
  --backend chinese-clip-large \
  --dtype fp16 \
  --device cuda \
  --labels output/label_sheets/label_template.csv
```

Kết quả kỳ vọng:

| Phương pháp | Độ chính xác top-1 |
|---|---:|
| Embedding | 28/59 = 0.4746 |
| Histogram | 26/59 = 0.4407 |

## Fine-tune Chinese-CLIP

Bước này tương ứng với **mục IV** và **mục VII** của báo cáo.

### Tải font và sinh dữ liệu huấn luyện

```bash
bash download_fonts.sh

$PY render_fonts.py
$PY scan_augment.py --calibrate

$PY finetune_glyph.py --smoke
$PY finetune_glyph.py --epochs 6 --device cuda
```

Mô tả các bước:

| Lệnh | Chức năng |
|---|---|
| `download_fonts.sh` | Tải 7 font Hán-Nôm tự do vào `./fonts`, dung lượng khoảng 200 MB |
| `render_fonts.py` | Render 26.044 ký tự qua 7 font, tạo 131.604 ảnh |
| `scan_augment.py --calibrate` | Hiệu chỉnh pipeline mô phỏng suy giảm chất lượng scan |
| `finetune_glyph.py --smoke` | Chạy thử pipeline với 200 lớp, khoảng 1 phút |
| `finetune_glyph.py --epochs 6 --device cuda` | Fine-tune mô hình, khoảng 25 phút |

Checkpoint sau huấn luyện được lưu tại:

```text
output/finetune/best.pt
```

`finetune_glyph.py` gọi hàm `scan_augment.degrade` trực tiếp trong `DataLoader`; do đó không cần chạy `render_fonts.py --augment`.

Trong quá trình huấn luyện, theo dõi cột `cos=` xuất hiện mỗi 600 bước. Giá trị này là cosine trung bình giữa các cặp embedding ngẫu nhiên và cần giảm từ khoảng 0.89 về 0.00.

Nếu giá trị `cos` tiến về 1.0, biểu diễn embedding đang gặp hiện tượng collapse. Trong trường hợp này, nên dừng huấn luyện thay vì tiếp tục chờ hết epoch.

Để tái lập trường hợp thất bại được ghi trong báo cáo tại mục VII-C:

```bash
$PY finetune_glyph.py --loss arcface
```

## Đánh giá mô hình fine-tuned

Có thể bỏ qua bước fine-tune và tải trực tiếp checkpoint đã công bố:

```bash
mkdir -p output/finetune

curl -L -o output/finetune/best.pt \
  https://huggingface.co/vohoangkh4ng/chinese-clip-ft-sinonom/resolve/main/best_fp16.pt
```

Sau đó chạy lại pipeline đánh giá với backend `chinese-clip-ft`:

```bash
$PY search_all_chars_in_corpus.py \
  --backend chinese-clip-ft \
  --dtype fp16 \
  --device cuda

$PY evaluate_test_images.py \
  --backend chinese-clip-ft \
  --dtype fp16 \
  --device cuda

$PY evaluate_test_images.py \
  --part 2 \
  --backend chinese-clip-ft \
  --dtype fp16 \
  --device cuda \
  --labels output/label_sheets/label_template.csv

$PY evaluate_test_images.py \
  --part 2 \
  --backend chinese-clip-ft \
  --dtype fp16 \
  --device cuda \
  --labels output/label_sheets/label_template.csv \
  --min-confidence high
```

### Kết quả kỳ vọng

| Kịch bản | Kết quả |
|---|---:|
| Phần 1 — `hit@1` | 35/59 = 0.5932 |
| Phần 2 — top-1 | 48/59 = 0.8136 |
| Phần 2 — MRR | 0.8983 |
| Phần 2 — lọc `high` confidence | 45/53 = 0.8491 |

Checkpoint FP16 cho embedding giống hệt checkpoint FP32. Đường suy luận gọi `model.to(fp16)` ngay sau khi nạp mô hình. Khác biệt tuyệt đối lớn nhất giữa hai phiên bản đã được kiểm tra trên toàn bộ 26.044 vector và bằng 0.0.

## Đánh giá tầng xếp hạng lại

Bước này tương ứng với **mục VIII** của báo cáo.

```bash
S="--suite render --sample 600"

$PY evaluate_rerank.py $S --no-rerank
$PY evaluate_rerank.py $S --oracle-meta
$PY evaluate_rerank.py $S
$PY evaluate_rerank.py $S --normalize none
```

Đây là kết quả âm và được báo cáo trung thực trong dự án:

- Oracle cho thấy còn khoảng **+17.5 điểm** dư địa cải thiện.
- Tuy nhiên, bước suy ra bộ thủ từ ảnh truy vấn chỉ đạt **11.86%**, nên tầng xếp hạng lại hiện chưa mang lại lợi ích thực tế.

## Dựng báo cáo và gói nộp

```bash
$PY make_figures.py
bash report/diagrams/build.sh
tectonic -X compile report/paper.tex
$PY build_report.py
$PY package_submission.py --zip
```

| Lệnh | Kết quả |
|---|---|
| `make_figures.py` | Sinh 5 hình vào `report/figs/*.pdf` |
| `report/diagrams/build.sh` | Sinh 9 sơ đồ TikZ thành PDF |
| `tectonic -X compile report/paper.tex` | Biên dịch `report/paper.pdf` 12 trang |
| `build_report.py` | Tạo `report/BaoCao.docx` và `report/BaoCao.pdf` |
| `package_submission.py --zip` | Tạo `submission/` và `submission.zip` |

File `paper.tex` bắt buộc phải biên dịch bằng **XeLaTeX** hoặc **LuaLaTeX**, không dùng `pdflatex`, vì báo cáo chứa ký tự Nôm ngoài Basic Multilingual Plane và cần `fontspec`.

Cách cài đặt Tectonic đơn giản nhất:

```bash
curl -fsSL https://drop-sh.fullyjustified.net | sh
```

Nếu chỉ cần đọc báo cáo, không cần cài đặt thêm vì [`report/paper.pdf`](report/paper.pdf) đã có sẵn trong repository.

## Xử lý sự cố thường gặp

| Hiện tượng | Nguyên nhân và cách xử lý |
|---|---|
| Kết quả chênh ở chữ số thập phân thứ tư trở đi | Bình thường do thứ tự tính toán số thực trên GPU có thể khác nhau |
| `hit@1` bằng 0 ở bước đánh giá fine-tuned | Kiểm tra `output/finetune/best.pt` đã tồn tại và được nạp thành công |
| Phần 2 cho kết quả sai | Kiểm tra `output/label_sheets/label_template.csv` còn nguyên vẹn |
| PDF hiển thị ô vuông thay vì chữ Nôm | Thiếu font; chạy `bash download_fonts.sh` |
| `pytest` báo skip | Thiếu `final_characteristics-v2.xlsx`; các test phụ thuộc dữ liệu sẽ skip thay vì fail |

Backend `chinese-clip-ft` được thiết kế để báo lỗi rõ ràng nếu thiếu checkpoint `output/finetune/best.pt`, thay vì âm thầm quay về chế độ zero-shot.

## Các thành phần chính

### Phần 1 — Tìm kiếm trên toàn corpus

Script chính:

```text
search_all_chars_in_corpus.py
```

Dữ liệu đầu vào:

- `images.zip`
- `final_characteristics-v2.xlsx`

Hệ thống trích xuất embedding từ ảnh glyph, sau đó sử dụng [FAISS](https://github.com/facebookresearch/faiss) để tìm top-k vector tương đồng trên toàn corpus.

Feature extractor có thể thay thế thông qua tham số `--backend` trong `feature_extractors.py`.

| Backend | Mô hình | Số chiều embedding |
|---|---|---:|
| `resnet18` | ResNet18 ImageNet baseline | 512 |
| `resnet18-gray` | ResNet18 với `conv1` khởi tạo pretrained | 512 |
| `chinese-clip` | `OFA-Sys/chinese-clip-vit-base-patch16` | 512 |
| `chinese-clip-large` | `OFA-Sys/chinese-clip-vit-large-patch14` | 768 |
| `chinese-clip-huge` | `OFA-Sys/chinese-clip-vit-huge-patch14` | 1024 |
| `dinov2` | `facebook/dinov2-base` | 1536 |
| `chinese-clip-ft` | Chinese-CLIP fine-tuned | 512 |

### So sánh feature extractor

Script:

```text
benchmark_extractors.py
```

Script đo tốc độ và ba chỉ số proxy chất lượng:

- `radical@k`
- `stroke_mae@k`
- `ids_jaccard@k`

Các chỉ số được suy ra từ các cột `RADICAL`, `STROKE_NUM` và `SHAPE_MORPH`, vốn không được pipeline chính sử dụng trực tiếp.

Kết quả chi tiết đã được ghi trong [`BENCHMARK.md`](BENCHMARK.md).

Tóm tắt chính:

- `chinese-clip-large` vượt baseline ResNet18 **2.31 lần** trên `radical@k`.
- `chinese-clip-large` đạt 0.5361 so với 0.2316 của ResNet18.
- `chinese-clip-huge` không cải thiện so với `chinese-clip-large`.
- `dinov2` mạnh hơn về `stroke_mae@k`, bổ trợ cho họ mô hình CLIP.

### So sánh phương pháp tìm kiếm

Script:

```text
benchmark_search.py
```

Script so sánh FAISS `IndexFlatIP` với HNSW, IVFFlat và IVFPQ về `recall@20` và độ trễ.

Kết luận:

- Với corpus 26.044 ký tự, tìm kiếm chỉ chiếm khoảng 6% tổng thời gian.
- `IndexFlatIP` được giữ làm phương pháp mặc định vì đảm bảo kết quả chính xác tuyệt đối.
- ANN chỉ nên được cân nhắc khi corpus vượt khoảng 300.000 ký tự.

### Phân tích trần của `radical@k`

Script:

```text
analyze_metric_ceiling.py
```

Trần lý thuyết của `radical@20` là **0.9862**. Do đó, kết quả dừng ở khoảng 0.5 không phải do giới hạn top-k.

Tuy nhiên, `RADICAL` không phải nhãn thị giác thuần túy:

- Bộ thủ chỉ thực sự xuất hiện rõ trong hình dạng chữ ở 56.7% ký tự.
- Một oracle biết trước phân rã IDS cũng chỉ đạt 0.7338.
- So với trần oracle này, `chinese-clip-large` đạt 73% quãng đường và cao hơn 24.4 lần so với mức ngẫu nhiên.

### Sinh cặp dương để fine-tune

Script:

```text
render_fonts.py
```

Corpus gốc chỉ có một ảnh cho mỗi ký tự, nên không có cặp dương dạng “cùng ký tự nhưng khác kiểu chữ” để huấn luyện tính bất biến với phong cách chữ.

Script render lại toàn bộ 26.044 ký tự thông qua 7 font Hán-Nôm tự do, bao gồm minh, tống, khải, hắc và phỏng tống.

Kết quả:

- Phủ 100% số ký tự trong corpus.
- Tạo 131.604 ảnh huấn luyện.
- Nhãn được gán theo mã Unicode.

### Mô phỏng đặc tính scan thật

Script:

```text
scan_augment.py
```

Ảnh render sạch có phân phối khác đáng kể so với ảnh scan viết tay. Trên 59 ảnh scan thật, hệ thống đo được khác biệt chủ yếu ở:

- Độ nét: 6.55 lần
- Tương phản: 2.54 lần
- Độ dày nét
- Mức nhiễu

Hàm `degrade()` mô phỏng sáu trục suy giảm này và được hiệu chỉnh bằng `--calibrate`.

Sau hiệu chỉnh:

- Sai lệch log giảm từ 0.880 xuống 0.103.
- `hit@1` trên ảnh render tăng từ 0.70 lên mức phù hợp hơn với scan thật.
- Khoảng cách còn lại chủ yếu đến từ khác biệt cấu trúc giữa chữ in và chữ viết tay, bút lông hoặc hành thư.

### Đánh giá trên ảnh truy vấn thật

Script:

```text
evaluate_test_images.py
```

Tên file trong `test_images/` được đặt theo quy tắc Telex. Ví dụ, `cofn.jpg` tương ứng với chữ “còn”. Nhờ đó, nhãn thật có thể được giải mã từ tên file.

Đây là phép đánh giá duy nhất không phải proxy trong dự án.

### Phần 2 — Tìm kiếm trong nhóm cùng âm Quốc Ngữ

Script chính:

```text
search_use_QuocNgu_mapping.py
```

Dữ liệu đầu vào:

- `images.zip`
- `final_characteristics-v2.xlsx`
- `QuocNgu_SinoNom_Dic.xlsx`

Ý tưởng tương tự Phần 1, nhưng chỉ so sánh các ký tự có cùng nghĩa hoặc cùng âm Quốc Ngữ. Do phạm vi tìm kiếm nhỏ hơn, script sử dụng sắp xếp thông thường thay vì FAISS.

## Mô hình đã công bố

Mô hình fine-tuned được công bố trên Hugging Face:

<https://huggingface.co/vohoangkh4ng/chinese-clip-ft-sinonom>

Thông tin checkpoint:

- Định dạng: FP16
- Dung lượng: 172 MB
- Huấn luyện bằng SupCon trên 141.981 ảnh render đa font
- Nhãn huấn luyện: mã Unicode
- Tập đánh giá: 59 ảnh scan viết tay, không sử dụng trong huấn luyện

Model card bao gồm:

- Kết quả chính và khoảng tin cậy 95%
- Code sử dụng thử nghiệm
- Sáu hạn chế của mô hình
- Ghi nhận trường hợp ArcFace gặp collapse

## Kết quả fine-tune

| Phương pháp | Phần 1 — `hit@1` | Phần 2 — top-1 |
|---|---:|---:|
| Chinese-CLIP large zero-shot | 0.0847 | 0.4746 |
| **Chinese-CLIP fine-tuned** | **0.5932** | **0.8136** |

Hai khoảng tin cậy 95% của hai phương pháp không giao nhau. Điều này cho thấy sự cải thiện là có ý nghĩa thống kê ở mức mẫu n = 59.

Các lớp Unicode chưa từng xuất hiện trong tập huấn luyện vẫn đạt hiệu năng gần bằng các lớp đã thấy:

| Nhóm lớp | Độ chính xác |
|---|---:|
| Lớp chưa thấy khi huấn luyện | 0.9939 |
| Lớp đã thấy khi huấn luyện | 0.9954 |

Điều này cho thấy mô hình không chỉ ghi nhớ các lớp huấn luyện.

## Báo cáo

Báo cáo chính:

```text
report/paper.pdf
```

Đặc điểm:

- 12 trang
- Định dạng bài hội nghị IEEEtran hai cột
- 13 hình
- 5 biểu đồ số liệu
- 1 ảnh phóng to
- 7 sơ đồ TikZ
- 3 phụ lục: lệnh tái lập, môi trường tính toán và cấu trúc gói nộp

Nguồn báo cáo:

```text
report/paper.tex
```

Các hình được sinh tự động từ số liệu thực nghiệm bằng:

```text
make_figures.py
```

Không nên chỉnh sửa trực tiếp các file PDF trong `report/figs/`. Cần sửa script sinh hình rồi chạy lại.

## Đóng gói bài nộp

Script:

```text
package_submission.py
```

Lệnh:

```bash
$PY package_submission.py --zip
```

Gói nộp bao gồm:

- Mã nguồn
- Tập đánh giá và nhãn gán tay
- Checkpoint FP16
- Báo cáo
- `MANIFEST.md` kèm checksum

Mô hình pretrained bên ngoài chỉ được ghi nhận định danh, không được đóng gói kèm trong bài nộp.

## Tài liệu tham khảo

- Ý tưởng thay thế feature extractor bằng DINOv2 và MetaCLIP thay cho ResNet18.
- Ý tưởng phân rã thành phần ký tự Hán-Nôm:
  - Paper: <https://arxiv.org/pdf/2309.01083>
  - Source code: <https://github.com/FudanVI/FudanOCR/tree/main>
- Chinese-CLIP: <https://huggingface.co/OFA-Sys/chinese-clip-vit-base-patch16>
- FAISS: <https://github.com/facebookresearch/faiss>
- Tectonic: <https://tectonic-typesetting.github.io/>

## Hướng cải tiến

Các hướng phát triển được xếp theo thứ tự chi phí tăng dần:

1. ~~Gán nhãn `test_images/`~~ — đã hoàn thành với 59/59 ảnh.
2. **Mở rộng tập scan thật.** Đây là nút thắt hiện tại. Với n = 59, khoảng tin cậy 95% rộng khoảng ±13.3 điểm. Cần khoảng n = 150 để giảm xuống khoảng ±8 điểm.
3. **Đánh giá bằng người trên khoảng 200 cặp.** Các chỉ số còn lại đều dựa trên nhãn yếu hoặc proxy.
4. **Ensemble `chinese-clip-large` và `dinov2`.** Hai mô hình chỉ trùng 12.9% top-k và mạnh ở các chỉ số khác nhau.
5. ~~Fine-tune metric learning~~ — đã hoàn thành.
6. **Hard negative mining.** Loss giảm nhanh về 0.0068 sau 400 bước vì các lớp lấy ngẫu nhiên từ 23.440 lớp vẫn tương đối dễ phân biệt. Bước tiếp theo nên đưa các ký tự dễ nhầm vào cùng batch.
7. ~~Thử các embedding model dòng Transformer~~ — đã thực hiện và ghi trong `BENCHMARK.md`.
