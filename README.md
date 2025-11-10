# HarmonyOS Scientific Calculator

一个基于HarmonyOS NEXT系统开发的功能完整的科学计算器应用，支持基础计算和高级科学运算。

---

## 项目概述

本项目是一个跨平台科学计算器应用，针对HarmonyOS NEXT操作系统进行优化。计算器支持两种操作模式：
- **基础模式**: 提供四则运算、百分比计算、符号切换等基本功能
- **科学模式**: 提供三角函数、对数函数、幂运算、阶乘等高级数学函数

### 核心特性

功能特性
- 响应式UI设计，支持手机、平板等多种设备
- 基础计算与科学计算模式切换
- 完整的数学函数支持（三角、对数、幂运算等）
- 优雅的暗色主题UI
- 高精度计算与错误处理
- 科学计数法显示支持

### 支持的运算

**基础运算**: 加、减、乘、除、取余、百分比

**科学函数**: 
- 三角函数: sin, cos, tan（弧度制）
- 对数函数: ln, log（常用对数）
- 其他: 平方根(√)、倒数(1/x)、阶乘(!)、幂运算(x^y, y√x)、圆周率(π)

---

## 技术栈

- **平台**: HarmonyOS NEXT（OpenHarmony）
- **开发语言**: ArkTS
- **开发工具**: DevEco Studio 6.0.0 Release
- **系统要求**: Windows 11
- **API等级**: HarmonyOS NEXT

### 项目依赖

```json
{
  "devDependencies": {
    "@ohos/hypium": "1.0.21",
    "@ohos/hamock": "1.0.0"
  }
}
```

---

## 项目结构

```
Harmony-Scientific-Calculator/
├── AppScope/                           # 应用全局配置
│   ├── app.json5                      # 应用清单文件
│   └── resources/                     # 全局资源
│
├── entry/                             # 应用主模块
│   ├── src/main/
│   │   ├── ets/
│   │   │   ├── entryability/          # 应用入口Ability
│   │   │   │   ├── EntryAbility.ets   # 生命周期管理
│   │   │   │   └── EntryBackupAbility.ets
│   │   │   ├── entrybackupability/    # 备份功能
│   │   │   └── pages/
│   │   │       └── Index.ets          # 计算器主页面（核心实现）
│   │   ├── module.json5               # 模块配置
│   │   └── resources/                 # 应用资源
│   │       ├── base/
│   │       │   ├── element/           # 字符串、颜色配置
│   │       │   └── media/             # 图标、图片资源
│   │       └── dark/                  # 深色主题资源
│   │
│   ├── test/                          # 测试模块
│   │   └── *.test.ets                 # 单元测试
│   │
│   └── build/                         # 构建产物
│       └── default/
│           ├── generated/             # 自动生成文件
│           └── outputs/               # 编译输出（.hap应用包）
│
├── hvigor/                            # Hvigor构建配置
└── oh_modules/                        # 第三方模块依赖
```

### 核心文件说明

| 文件 | 说明 |
|------|------|
| `Index.ets` | 计算器UI和业务逻辑的核心实现（约800+行） |
| `EntryAbility.ets` | 应用生命周期管理 |
| `app.json5` | 应用配置（包名：com.example.scicalculator）|
| `module.json5` | 模块配置和页面路由 |

---

## 核心功能实现

### 1. 表达式求值引擎

采用**逆波兰表示法(RPN)** + **Shunting-yard算法**实现表达式计算：

```
输入: 2 + 3 * 4
→ 符号转换：2 + 3 * 4
→ 中缀转后缀(RPN)：2 3 4 * +
→ 栈计算：2 (3*4=12) 12+2=14
```

**关键方法**:
- `tokenize()` - 词法分析，将输入字符串转换为token
- `toRPN()` - 中缀表达式转后缀表达式（Shunting-yard算法）
- `evalRPN()` - 使用栈计算后缀表达式

### 2. 智能输入处理

- **自动补全括号**: 自动补全未闭合的括号
- **隐式乘法**: `2π` 自动转换为 `2*π`
- **符号切换**: 支持 `(0-x)` 形式的负数处理
- **百分比计算**: 直接在表达式中使用 `%` 符号
- **退格功能**: 逐级撤销函数名和运算符

### 3. 高精度数值显示

```typescript
formatNumber(n: number): string {
  // 1. 处理特殊值 (Infinity, NaN, -0)
  // 2. 整数精度检验
  // 3. 科学计数法处理 (< 1e-6 或 >= 1e9)
  // 4. 小数位舍入 (9位精度)
}
```

---

## UI界面设计

### 基础计算器模式 (5行按钮)

```
┌─────────────────────────┐
│     上一步表达式显示     │  ← 运算历史
│     当前输入/结果       │  ← 主显示区
├─────────────────────────┤
│ AC   +/-   %   ÷       │
│ 7    8    9   ×       │
│ 4    5    6   −       │
│ 1    2    3   +       │
│ X    0    .   =       │
└─────────────────────────┘
  ↑                    
  科学计算器模式切换按键
```

### 科学计算模式 (追加3行)

```
额外科学函数:
┌─────────────────────────┐
│ 1/x √x y√x x² xʸ      │
│ ln  log sin cos tan    │
│ (   )  10ˣ  x!  π     │
└─────────────────────────┘
```

### UI配色方案

| 元素 | 颜色 | 用途 |
|------|------|------|
| 背景 | #000000 (黑色) | 主题背景 |
| 标准按键 | #333333 (深灰) | 普通数字/操作 |
| 功能按键 | #A5A5A5 (浅灰) | AC, +/-, % |
| 运算符按键 | #FF9500 (橙色) | +, −, ×, ÷, = |
| 文字 | #FFFFFF (白色) | 高对比度显示 |

---

## 快速开始

### 环境要求

- DevEco Studio 6.0.0 Release 或更新版本
- HarmonyOS NEXT SDK
- Windows 11 系统
- 至少4GB内存

### 开发环境配置

1. **安装DevEco Studio**
   - 从官方网站下载DevEco Studio 6.0.0+版本

2. **项目导入**
   ```
   File → Open → 选择项目根目录
   ```

3. **构建项目**
   ```
   Build → Build Hap(s)/App(s)
   ```

4. **运行应用**
   - 连接HarmonyOS设备或启动模拟器
   - 点击 Run → Run 'entry'

### 编译输出

编译成功后，生成的应用包位于：
```
entry/build/default/outputs/default/entry-default-unsigned.hap
```

---

## 使用说明

### 基础操作

1. **数字输入**: 直接点击数字按键
2. **四则运算**: 点击 `+`, `−`, `×`, `÷` 按键
3. **计算结果**: 点击 `=` 按键
4. **全部清除**: 点击 `AC` 按键
5. **切换符号**: 点击 `+/-` 改变正负号
6. **百分比**: 点击 `%` 进行百分比计算

### 科学计算

1. **切换模式**: 点击基础模式右下角的 `X` 按键
2. **三角函数**: 输入数值后点击 `sin`, `cos`, `tan`（结果以弧度制计算）
3. **对数函数**: 输入数值后点击 `ln` 或 `log`
4. **特殊运算**:
   - `√x` - 平方根
   - `1/x` - 倒数
   - `x^y` - 幂运算
   - `y√x` - 通用根运算
   - `x!` - 阶乘
   - `π` - 圆周率

### 示例计算

- `2 + 3 × 4` → 14
- `sin(90)` → 1（使用圆周率自动转换为弧度）
- `√16` → 4
- `log(100)` → 2
- `5!` → 120

---

## 核心算法详解

### Shunting-yard 算法（调车场算法）

这是将中缀表达式转换为后缀表达式的经典算法：

**处理流程**:
1. 逐个读取输入token
2. 数字直接输出到结果队列
3. 操作符：根据优先级和结合性，将栈顶操作符弹出
4. 右括号：弹出所有操作符直到找到左括号
5. 最后：弹出栈中所有操作符

**优先级设定** (从高到低):
- 5: 函数(sin, cos等)、阶乘(!)
- 4: 幂运算(^、y√x)
- 3: 乘法、除法
- 2: 加法、减法

**结合性**:
- 右结合: `^` (如 `2^3^2 = 2^(3^2)`)
- 左结合: 其他操作符

### 数值精度处理

项目采用9位有效数字的精度标准：

```typescript
// 舍入处理避免浮点误差
const PREC = 9;
const factor = Math.pow(10, PREC);
const rounded = Math.round(n * factor) / factor;

// 科学计数法处理
if (absn >= 1e9 || (absn > 0 && absn < 1e-6)) {
  return n.toExponential(PREC - 1);
}
```

---

## 测试

项目包含单元测试文件，使用HarmonyOS的Hypium测试框架：

```
entry/
├── ohosTest/
│   ├── Ability.test.ets      # 能力测试
│   └── List.test.ets         # 列表测试
└── test/
    ├── LocalUnit.test.ets    # 本地单元测试
    └── List.test.ets
```

**运行测试**:
```
Build → Run Tests
```

---

## 个性化修改

### 修改配色

编辑 `Index.ets` 中的颜色常量：

```typescript
private BLACK: ResourceColor = Color.Black           // 背景
private LIGHT_GRAY_BTN: ResourceColor = '#A5A5A5'   // 功能键
private DARK_GRAY_BTN: ResourceColor = '#333333'    // 标准键
private ORANGE_BTN: ResourceColor = '#FF9500'       // 运算符
private TXT_WHITE: ResourceColor = '#FFFFFF'        // 文字
```

### 修改按钮排列

在 `Index.ets` 中修改对应的行数组：

```typescript
private row1: string[] = ['AC', '+/-', '%', '÷']   // 第一行
private row2: string[] = ['7', '8', '9', 'x']      // 第二行
// ... 依此修改
```

### 调整字体大小

```typescript
@State bigFont: number = 56      // 主显示字体
@State smallFont: number = 52    // 历史显示字体
```

---

## 代码统计

- **总代码行数**: 800+ 行
- **主要文件**: `Index.ets`（计算器核心逻辑）
- **配置文件**: 3个 JSON5 配置
- **测试覆盖**: Hypium测试框架集成

---

## 构建配置

### 项目配置文件

- `oh-package.json5` - 项目依赖管理
- `hvigorfile.ts` - Hvigor构建脚本
- `code-linter.json5` - 代码检查配置
- `build-profile.json5` - 编译配置

---

## 已知问题与改进方向

### 当前实现
完整的四则运算  
科学函数支持  
高精度计算  
UI响应式设计

### 可能的改进方向
- [ ] 添加计算历史记录功能
- [ ] 支持更多数学函数（beta函数、gamma函数等）
- [ ] 添加主题切换（浅色/深色）
- [ ] 支持键盘输入
- [ ] 添加计算步骤详解
- [ ] 表达式编辑功能

---

## 开发信息

- **开发平台**: DevEco Studio 6.0.0 Release
- **开发语言**: ArkTS
- **应用包名**: com.example.scicalculator
- **版本**: 1.0.0
- **支持设备**: 手机、平板、2-in-1设备

---

## 参考资源

- [HarmonyOS NEXT官方文档](https://developer.huawei.com/consumer/cn/doc/design/harmonyos-guides/introduce-0000001428061700)
- [ArkTS语言文档](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-get-started-0000001504769321)
- [DevEco Studio用户指南](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/deveco-studio-user-guide-0000001419762972)
- 逆波兰表示法 (RPN)
- Shunting-yard算法