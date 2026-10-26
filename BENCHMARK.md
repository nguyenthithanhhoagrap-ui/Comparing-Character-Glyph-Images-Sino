# Tìm kiếm ký tự Hán-Nôm tương đồng bằng hình dạng glyph

[![Python](https://img.shields.io/badge/Python-3.10%2B-3776AB)](#)
[![PyTorch](https://img.shields.io/badge/PyTorch-2.6-EE4C2C)](#)
[![Chinese-CLIP](https://img.shields.io/badge/Chinese--CLIP-Fine--tuned-blue)](https://huggingface.co/vohoangkh4ng/chinese-clip-ft-sinonom)
[![FAISS](https://img.shields.io/badge/Search-FAISS-005571)](#)
[![Hugging Face](https://img.shields.io/badge/Model-Hugging_Face-yellow)](https://huggingface.co/vohoangkh4ng/chinese-clip-ft-sinonom)

Dự án xây dựng hệ thống tìm kiếm ký tự Hán-Nôm tương đồng dựa trên **hình dạng glyph**. Cho một ảnh ký tự Hán-Nôm đầu vào, hệ thống trích xuất embedding thị giác và tìm các ký tự có hình dạng gần nhất trong corpus gồm **26.044 ảnh ký tự**.

Hệ thống hỗ trợ hai chế độ tìm kiếm:

| Chế độ | Mô tả |
|---|---|
| **Phần 1 — Tìm kiếm toàn corpus** | Tìm các ký tự tương đồng nhất khi chưa biết ký tự truy vấn đọc là gì |
| **Phần 2 — Xếp hạng trong nhóm cùng âm Quốc Ngữ** | Xếp hạng các ký tự có cùng âm đọc Quốc Ngữ khi đã biết âm đọc của ký tự truy vấn |

## Kết quả chính

Kết quả được đánh giá trên **59 ảnh scan viết tay thật**. Không có pixel nào trong tập đánh giá này được sử dụng cho quá trình huấn luyện.

| Phương pháp | Phần 1 — `hit@1` trên 26.044 ký tự | Phần 2 — đúng top-1 trong nhóm | `radical@k` toàn corpus |
|---|---:|---:|---:|
| ResNet18 baseline | — | 0.4407 | 0.2316 |
| Chinese-CLIP zero-shot | 0.0847 | 0.4746 | 0.5361 |
| **Chinese-CLIP fine-tuned** | **0.5932** | **0.8136** | — |

Mô hình fine-tuned cải thiện `hit@1` từ **0.0847 lên 0.5932** ở Phần 1 và tăng độ chính xác top-1 từ **0.4746 lên 0.8136** ở Phần 2.

## Tài nguyên dự án

- **Repository:** <https://github.com/vo-hoang-kh4ng/comparing-character-glyph-images-Sino-N-m>
- **Mô hình đã huấn luyện:** <https://huggingface.co/vohoangkh4ng/chinese-clip-ft-sinonom>
- **Báo cáo:** [`report/paper.pdf`](report/paper.pdf) — 12 trang, định dạng bài hội nghị
- **Kết quả benchmark chi tiết:** [`BENCHMARK.md`](BENCHMARK.md)
- **Hướng dẫn cài đặt script:** [`CLAUDE.md`](CLAUDE.md)

## Kiến trúc hệ thống

```text
Ảnh glyph Hán-Nôm
        |
        v
Feature Extractor
(ResNet18 / Chinese-CLIP / DINOv2 / Fine-tuned CLIP)
        |
        v
Chuẩn hóa L2 embedding
        |
        v
FAISS IndexFlatIP
        |
        v
Top-k ký tự tương đồng
```

Pipeline tìm kiếm chỉ sử dụng thông tin từ ảnh glyph. Embedding được chuẩn hóa L2, sau đó FAISS `IndexFlatIP` được sử dụng để tìm các vector gần nhất theo cosine similarity.

## Các phương pháp đánh giá

### Phần 1 — Tìm kiếm trên toàn corpus

Với một ảnh glyph truy vấn, hệ thống so sánh embedding của ảnh đó với toàn bộ 26.044 embedding trong corpus và trả về top-k ký tự tương đồng nhất.

Chỉ số đánh giá chính:

- `hit@1`: tỷ lệ truy vấn mà kết quả đúng xuất hiện ở vị trí đầu tiên.
- `hit@k`: tỷ lệ truy vấn mà kết quả đúng xuất hiện trong top-k.
- `MRR`: Mean Reciprocal Rank.

### Phần 2 — Xếp hạng trong nhóm cùng âm Quốc Ngữ

Khi biết âm đọc Quốc Ngữ của ký tự truy vấn, hệ thống chỉ xếp hạng trong nhóm các ký tự có cùng âm đọc. Phạm vi ứng viên thường chỉ gồm vài chục ký tự thay vì toàn bộ corpus.

Chỉ số đánh giá chính:

- Top-1 accuracy trong nhóm cùng âm Quốc Ngữ.
- MRR trong nhóm ứng viên.

### Chỉ số proxy trên corpus

Ngoài đánh giá trên ảnh scan thật, dự án sử dụng các chỉ số proxy để so sánh nhanh chất lượng của các feature extractor:

| Chỉ số | Ý nghĩa |
|---|---|
| `radical@k` | Tỷ lệ các ký tự trong top-k cùng bộ thủ với ký tự truy vấn |
| `stroke_mae@k` | Sai số trung bình tuyệt đối về số nét |
| `ids_jaccard@k` | Độ tương đồng Jaccard giữa các thành phần IDS |

Các chỉ số này được suy ra từ `RADICAL`, `STROKE_NUM` và `SHAPE_MORPH` trong `final_characteristics-v2.xlsx`. Chúng là nhãn yếu, phù hợp để so sánh tương đối giữa các backend nhưng không thay thế đánh giá bằng người.

## Feature Extractor

Feature extractor có thể thay thế thông qua tham số `--backend`.

| Backend | Mô hình | Số chiều embedding | Ghi chú |
|---|---|---:|---|
| `resnet18` | ResNet18 ImageNet | 512 | Baseline gốc |
| `resnet18-gray` | ResNet18 với `conv1` khởi tạo pretrained | 512 | Biến thể kiểm chứng giả thuyết |
| `chinese-clip` | `OFA-Sys/chinese-clip-vit-base-patch16` | 512 | ViT-B/16 |
| `chinese-clip-large` | `OFA-Sys/chinese-clip-vit-large-patch14` | 768 | ViT-L/14, hiệu quả nhất trong zero-shot |
| `chinese-clip-huge` | `OFA-Sys/chinese-clip-vit-huge-patch14` | 1024 | ViT-H/14 |
| `dinov2` | `facebook/dinov2-base` | 1536 | ViT tự giám sát |
| `chinese-clip-ft` | Chinese-CLIP fine-tuned | 512 | Hiệu quả nhất trên scan thật |

## Kết quả so sánh feature extractor

Kết quả dưới đây được đo trên toàn corpus 26.044 glyph với `top-k = 20`.

| Backend | `radical@k` | `stroke_mae@k` | `ids_jaccard@k` |
|---|---:|---:|---:|
| `resnet18` | 0.2316 | 2.8942 | 0.1031 |
| `resnet18-gray` | 0.2202 | 2.5658 | 0.1020 |
| `chinese-clip` | 0.4843 | 2.6296 | 0.1997 |
| **`chinese-clip-large`** | **0.5361** | 2.6992 | 0.2113 |
| `chinese-clip-huge` | 0.5147 | 2.6547 | **0.2144** |
| `dinov2` | 0.3081 | **2.3397** | 0.1251 |

### Nhận xét

- `chinese-clip-large` vượt baseline ResNet18 **2.31 lần** trên `radical@k` và **2.05 lần** trên `ids_jaccard@k`.
- Việc tăng kích thước mô hình từ `large` lên `huge` không mang lại cải thiện trên `radical@k`.
- `dinov2` tốt nhất về `stroke_mae@k`, cho thấy nó nắm bắt mật độ nét tốt hơn, trong khi Chinese-CLIP mạnh hơn về cấu trúc và bộ thủ.
- Hai mô hình `chinese-clip-large` và `dinov2` chỉ trùng khoảng 12.9% kết quả top-20, do đó có tiềm năng kết hợp trong ensemble hoặc reranking.

## Tái lập kết quả

### Chuẩn bị dữ liệu

Các dữ liệu sau đã có sẵn trong repository:

| Thành phần | Đường dẫn | Mô tả |
|---|---|---|
| 59 ảnh scan viết tay | `test_images/` | Tập đánh giá thật của dự án |
| Nhãn Phần 2 | `output/label_sheets/label_template.csv` | Nhãn gán tay cho Phần 2 |

**Quan trọng:** Không xoá hoặc ghi đè `output/label_sheets/label_template.csv`. Đây là nhãn do người gán tay và không thể sinh lại bằng code.

Dữ liệu đề bài phát cần được đặt vào thư mục gốc repository:

| Dữ liệu | Vị trí đặt | Bắt buộc cho |
|---|---|---|
| `images/` — giải nén từ `images.zip` | `./images/` | Mọi thí nghiệm |
| `final_characteristics-v2.xlsx` | `./` | Mọi thí nghiệm |
| `QuocNgu_SinoNom_Dic.xlsx` | `./` | Phần 2 |

Bản sao dữ liệu dự phòng:

<https://drive.google.com/drive/folders/12kfJjiM866taJS_-QhOS30TmRi1000Bt>

### Yêu cầu phần cứng

- Các bước trích xuất embedding, đánh giá và tìm kiếm có thể chạy trên CPU.
- Fine-tune yêu cầu GPU có tối thiểu 6 GB VRAM.
- Trong thực nghiệm, mức sử dụng VRAM cao nhất khoảng 3.7 GB.
- Nếu không có GPU, có thể tải checkpoint fine-tuned từ Hugging Face thay vì huấn luyện lại.

### Cài đặt

```bash
git clone https://github.com/vo-hoang-kh4ng/comparing-character-glyph-images-Sino-N-m.git
cd comparing-character-glyph-images-Sino-N-m

python3 -m venv .venv
.venv/bin/pip install -r requirements.txt

.venv/bin/python -m pytest -q
# Kỳ vọng: 66 passed
```

Toàn bộ lệnh nên được chạy từ thư mục gốc repository. Các script truy cập các thư mục tương đối như `./images`, `./output`, `./test_images` và `./fonts`.

Ở lần chạy đầu, Hugging Face sẽ tải trọng số mô hình vào `~/.cache/huggingface`.

<details>
<summary>Cài đặt trên máy chủ dùng chung đã có PyTorch</summary>

```bash
python3 -m venv --system-site-packages .venv
.venv/bin/pip install "torchvision==0.21.0" faiss-cpu opencv-python-headless
```

`torchvision` phải tương thích với phiên bản PyTorch đã cài. Với PyTorch 2.6.0, sử dụng `torchvision==0.21.0`.

</details>

## Đánh giá proxy trên corpus

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

Embedding được cache tại:

```text
output/embeddings_<backend>.npz
```

## Đánh giá zero-shot trên scan thật

### Phần 1

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
| `hit@5` | 0.1525 |
| `hit@10` | 0.1864 |
| `hit@20` | 0.2034 |
| `MRR` | 0.1143 |

### Phần 2

```bash
$PY evaluate_test_images.py \
  --part 2 \
  --backend chinese-clip-large \
  --dtype fp16 \
  --device cuda \
  --labels output/label_sheets/label_template.csv
```

Kết quả kỳ vọng:

| Phương pháp | Top-1 accuracy |
|---|---:|
| Embedding | 28/59 = 0.4746 |
| Histogram | 26/59 = 0.4407 |

## Fine-tune Chinese-CLIP

### Tải font và sinh dữ liệu

```bash
bash download_fonts.sh

$PY render_fonts.py
$PY scan_augment.py --calibrate

$PY finetune_glyph.py --smoke
$PY finetune_glyph.py --epochs 6 --device cuda
```

| Lệnh | Chức năng |
|---|---|
| `download_fonts.sh` | Tải 7 font Hán-Nôm tự do |
| `render_fonts.py` | Render 26.044 ký tự qua nhiều font |
| `scan_augment.py --calibrate` | Hiệu chỉnh pipeline mô phỏng suy giảm scan |
| `finetune_glyph.py --smoke` | Kiểm tra pipeline huấn luyện |
| `finetune_glyph.py --epochs 6 --device cuda` | Huấn luyện mô hình |

Checkpoint sau huấn luyện:

```text
output/finetune/best.pt
```

### Cơ chế huấn luyện

- Backbone: Chinese-CLIP ViT-B/16
- Loss: Supervised Contrastive Learning, SupCon
- Nhiệt độ: 0.07
- Lấy mẫu: 24 lớp x 2 view mỗi batch
- Dữ liệu: 141.981 ảnh render đa font
- Suy giảm scan: áp dụng online trong `DataLoader`
- Optimizer: AdamW
- Thời lượng: khoảng 25 phút trên GPU

### Theo dõi quá trình huấn luyện

Trong log huấn luyện, theo dõi cột `cos=` xuất hiện mỗi 600 bước. Đây là cosine trung bình giữa các cặp embedding ngẫu nhiên.

- Giá trị bình thường: giảm từ khoảng 0.89 về 0.00.
- Dấu hiệu collapse: giá trị tiến về 1.0.

Nếu phát hiện collapse, nên dừng huấn luyện thay vì tiếp tục chạy hết epoch.

## Đánh giá mô hình fine-tuned

Có thể bỏ qua bước fine-tune và tải trực tiếp checkpoint đã công bố:

```bash
mkdir -p output/finetune

curl -L -o output/finetune/best.pt \
  https://huggingface.co/vohoangkh4ng/chinese-clip-ft-sinonom/resolve/main/best_fp16.pt
```

Sau đó chạy đánh giá:

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
| Phần 1 — `hit@10` | 0.7966 |
| Phần 1 — MRR | 0.6691 |
| Phần 2 — top-1 | 48/59 = 0.8136 |
| Phần 2 — MRR | 0.8983 |
| Phần 2 — lọc `high` confidence | 45/53 = 0.8491 |

Checkpoint FP16 cho embedding giống hệt checkpoint FP32. Khác biệt tuyệt đối lớn nhất giữa hai phiên bản trên toàn bộ 26.044 vector là 0.0.

## Tầng xếp hạng lại

```bash
S="--suite render --sample 600"

$PY evaluate_rerank.py $S --no-rerank
$PY evaluate_rerank.py $S --oracle-meta
$PY evaluate_rerank.py $S
$PY evaluate_rerank.py $S --normalize none
```

Đây là kết quả âm và được báo cáo trung thực:

- Oracle cho thấy còn khoảng +17.5 điểm dư địa.
- Tuy nhiên, bước suy ra bộ thủ từ ảnh truy vấn chỉ đạt 11.86% khi dùng tầng tìm kiếm zero-shot.
- Do đó, tầng xếp hạng lại hiện chưa mang lại lợi ích thực tế.

## Dựng báo cáo

```bash
$PY make_figures.py
bash report/diagrams/build.sh
tectonic -X compile report/paper.tex
$PY build_report.py
$PY package_submission.py --zip
```

| Lệnh | Kết quả |
|---|---|
| `make_figures.py` | Sinh các hình vào `report/figs/` |
| `report/diagrams/build.sh` | Biên dịch sơ đồ TikZ |
| `tectonic -X compile report/paper.tex` | Tạo `report/paper.pdf` |
| `build_report.py` | Tạo báo cáo DOCX và PDF |
| `package_submission.py --zip` | Tạo gói nộp `submission.zip` |

Báo cáo bắt buộc biên dịch bằng XeLaTeX hoặc LuaLaTeX vì chứa ký tự Nôm ngoài Basic Multilingual Plane.

Cài đặt Tectonic:

```bash
curl -fsSL https://drop-sh.fullyjustified.net | sh
```

## Xử lý sự cố

| Hiện tượng | Cách xử lý |
|---|---|
| Kết quả chênh ở chữ số thập phân thứ tư trở đi | Bình thường do thứ tự tính toán số thực trên GPU |
| `hit@1` bằng 0 ở bước fine-tuned | Kiểm tra `output/finetune/best.pt` đã tồn tại và được nạp |
| Phần 2 cho kết quả sai | Kiểm tra `output/label_sheets/label_template.csv` |
| PDF hiển thị ô vuông thay vì chữ Nôm | Chạy `bash download_fonts.sh` |
| `pytest` báo skip | Thiếu `final_characteristics-v2.xlsx` |

## Hạn chế

- Các chỉ số `radical@k`, `stroke_mae@k` và `ids_jaccard@k` là nhãn yếu, không phải đánh giá trực tiếp của con người.
- Tập scan thật hiện chỉ có 59 ảnh, nên khoảng tin cậy 95% còn rộng.
- Ảnh scan viết tay và corpus in bằng font có sự khác biệt lớn về phong cách thư pháp, độ nét, tương phản và nhiễu.
- Tầng xếp hạng lại bằng siêu dữ liệu chưa hiệu quả vì bước suy ra bộ thủ từ ảnh truy vấn còn yếu.
- Kết quả ANN chỉ được đo ở quy mô 26.044 ký tự; cần đo lại khi mở rộng corpus.

## Hướng cải tiến

1. **Mở rộng tập scan thật.** Đây là nút thắt lớn nhất. Cần khoảng 150 ảnh scan để giảm khoảng tin cậy xuống khoảng ±8 điểm.
2. **Đánh giá bằng người.** Nên đánh giá khoảng 200 cặp ký tự để kiểm chứng mức độ tương đồng thị giác thực sự.
3. **Ensemble Chinese-CLIP và DINOv2.** Hai mô hình có mức trùng lặp top-k thấp và mạnh ở các khía cạnh khác nhau.
4. **Hard negative mining.** Ưu tiên các cặp ký tự dễ nhầm trong cùng batch khi huấn luyện.
5. **Sử dụng dữ liệu thư pháp thật.** Các bộ dữ liệu như MCCD, NomNaOCR hoặc IHR-NomDB có thể bổ sung đặc trưng bút lông và chữ viết tay mà render font không tạo được.
6. **Đánh giá lại reranking với mô hình fine-tuned.** Vì độ chính xác suy ra bộ thủ tăng mạnh khi dùng checkpoint fine-tuned.

## Tài liệu tham khảo

- Chinese-CLIP: <https://huggingface.co/OFA-Sys/chinese-clip-vit-base-patch16>
- DINOv2: <https://github.com/facebookresearch/dinov2>
- FAISS: <https://github.com/facebookresearch/faiss>
- FudanOCR: <https://github.com/FudanVI/FudanOCR/tree/main>
- Paper tham khảo: <https://arxiv.org/pdf/2309.01083>
- Tectonic: <https://tectonic-typesetting.github.io/>
