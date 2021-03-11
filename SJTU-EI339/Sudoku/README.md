## 目录结构

│  README.md
│  Report.pdf     **报告**
└─opencv-sudoku-solver
    │  image_process.py   **预处理数据集**
    │  output_log.py    **保存运行日志**
    │  requirements.txt    **项目所需环境**
    │  solve_sudoku_puzzle.py   **求解数独**
    │  sudoku_puzzle.jpg
    │  train.py    **训练模型**
    │  train_digit_classifier.py
    ├─dataset
    │  └─EI339-CN
    ├─output
    │      
    ├─pyimagesearch
    │  │  
    │  ├─models
    │  │      lenet.py   **新的网络模型LeNet-5**
    │  │      sudokunet.py
    │  └─sudoku
    │          puzzle.py
    │          solve.py   **数独求解算法**
    └─test1

## How to Run

```bash
cd opencv-sudoku-solver
pip install -r requirements.txt
python train.py --model output/digit_classifier.h5
python solve_sudoku_puzzle.py --model output/digit_classifier.h5 --image sudoku_puzzle.jpg
```

## 备注

对于不同的图片，我选择了不同的模型，对应参数如下表

|         | learning rate | epoch |    model     |
| :-----: | :-----------: | :---: | :----------: |
| 1-1.jpg |    1.1e-3     |  40   | lr1.1ep40.h5 |
| 1-2.jpg |     1e-3      |  40   |  lr1ep40.h5  |
| 1-3.jpg |    1.1e-3     |  40   | lr1.1ep40.h5 |
| 1-4.jpg |    1.1e-3     |  40   | lr1.1ep40.h5 |
| 1-5.jpg |     1e-3      |  40   |  lr1ep40.h5  |
| 2-1.jpg |    1.1e-3     |  30   | lr1.1ep30.h5 |
| 2-2.jpg |    1.1e-3     |  40   | lr1.1ep40.h5 |
| 2-3.jpg |    1.1e-3     |  40   | lr1.1ep40.h5 |
| 2-4.jpg |     1e-3      |  40   |  lr1ep40.h5  |
| 2-5.jpg |    1.1e-3     |  30   | lr1.1ep30.h5 |

