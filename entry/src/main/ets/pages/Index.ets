interface ButtonSize {
  w: string | number
  h: number
  r: number
}

@Entry
@Component
struct Index {
  private BLACK: ResourceColor = Color.Black
  private LIGHT_GRAY_BTN: ResourceColor = '#A5A5A5'
  private DARK_GRAY_BTN: ResourceColor = '#333333'
  private ORANGE_BTN: ResourceColor = '#FF9500'
  private TXT_WHITE: ResourceColor = '#FFFFFF'

  @State bigFont: number = 56
  @State smallFont: number = 52
  @State upperLine: string = ''
  @State inputExpr: string = '0'
  @State isSci: boolean = false
  @State waitingForOperand: boolean = false

  private row1: string[] = ['AC', '+/-', '%', '÷']
  private row2: string[] = ['7', '8', '9', 'x']
  private row3: string[] = ['4', '5', '6', '-']
  private row4: string[] = ['1', '2', '3', '+']
  private row5: string[] = ['X', '0', '.', '=']

  private sci1: string[] = ['1/x', '√x', 'y√x', 'x²', 'xʸ']
  private sci2: string[] = ['ln', 'log', 'sin', 'cos', 'tan']
  private sci3: string[] = ['(', ')', '10ˣ', 'x!', 'π']

  private clearAll() {
    this.inputExpr = '0'
    this.upperLine = ''
    this.waitingForOperand = false
  }

  private backspace() {
    if (this.inputExpr.length <= 1) { this.inputExpr = '0'; return }

    const funcs = ['sin', 'cos', 'tan', 'ln', 'log', 'sqrt', 'inv', 'yroot', '!']
    for (const f of funcs) {
      if (this.inputExpr.endsWith(f + '(')) {
        this.inputExpr = this.inputExpr.slice(0, -f.length-1)
        return
      }
      if (this.inputExpr.endsWith(f)) {
        this.inputExpr = this.inputExpr.slice(0, -f.length)
        return
      }
    }

    this.inputExpr = this.inputExpr.slice(0, -1)
    if (this.inputExpr.trim() === '' || this.inputExpr === '-') this.inputExpr = '0'
  }

  private formatSciDisplay(token: string): string {
    if (token === 'yroot') return '√'
    return token
  }

  private isInitialZero(): boolean {
    return (this.inputExpr === '0' && this.upperLine === '') || this.waitingForOperand
  }

  private appendToken(tok: string) {
    if (tok === '-' && this.inputExpr === '0') {
      this.inputExpr = '-'
      return
    }
    if (this.inputExpr === '0') {
      if (tok === '.') {
        this.inputExpr = '0.'
        return
      }
      if (/^(sin|cos|tan|ln|log|π|√|1\/\(|√\()/.test(tok) || /^[0-9(]$/.test(tok)) {
        this.inputExpr = tok
        return
      }
    }

    const last = this.inputExpr.slice(-1)
    if (/[+\-x÷*/^]$/.test(last) && /[+\-x÷*/^]/.test(tok)) {
      this.inputExpr = this.inputExpr.slice(0, -1) + tok
      return
    }

    const needMul = /[0-9)!πx²]/.test(last) && tok !== 'yroot' &&
    /^(sin|cos|tan|ln|log|π|√|1\/\()$/.test(tok)
    if (needMul) this.inputExpr += 'x'

    this.inputExpr += tok

  }

  private extractPlainNumberForWrapping(): string | null {

    if (/^[+-]?[0-9.]+(?:e[+\-]?\d+)?$/i.test(this.inputExpr)) return this.inputExpr
    const m = this.inputExpr.match(/^\(0-([0-9.]+)\)$/)
    if (m) return '-' + m[1]
    if (this.inputExpr === 'π' || this.inputExpr === 'PI') return 'PI'
    return null
  }

  private handleOperator(op: string) {
    if (this.waitingForOperand) {
      this.upperLine = ''
      this.inputExpr = (this.inputExpr === 'Error' ? '0' : this.inputExpr) + op
      this.waitingForOperand = false
      return
    }
    this.appendToken(op)
  }

  private onBasicKey(key: string) {
    switch (key) {
      case 'AC':
        this.clearAll()
        break
      case '+/-': {
        this.toggleSign()
        break
      }
      case '%': {
        this.applyPercentToLastNumber()
        break
      }
      case '÷':
        this.handleOperator('÷')
        break
      case 'x':
        this.handleOperator('x')
        break
      case '-':
        this.handleOperator('-')
        break
      case '+':
        this.handleOperator('+')
        break
      case '=':
        this.evaluateAndShow()
        break
      case '.':
        if (this.waitingForOperand) {
          this.upperLine = ''
          this.inputExpr = '0.'
          this.waitingForOperand = false
          return
        }
        this.insertDot()
        break
      case 'X':
        this.isSci = !this.isSci
        break
      default:
        if (/^\d$/.test(key)) {
          if (this.waitingForOperand) {
            this.upperLine = ''
            this.inputExpr = key
            this.waitingForOperand = false
            return
          }
          if (this.inputExpr === '0') {
            this.inputExpr = key
          } else if (this.inputExpr === '-') {
            this.inputExpr += key
          } else {
            this.inputExpr += key
          }
        }
    }
  }

  private onSciKey(key: string) {
    const wrapFuncs = ['1/x', '√x', 'ln', 'log', 'sin', 'cos', 'tan']
    if (wrapFuncs.includes(key)) {
      const plain = this.extractPlainNumberForWrapping()
      if (plain !== null && (plain !== '0' || this.waitingForOperand)) {
        switch (key) {
          case '1/x': {
            this.inputExpr = `1/(${plain})`
            this.upperLine = ''
            this.waitingForOperand = false
            return
          }
          case '√x': {
            this.inputExpr = `√(${plain})`
            this.upperLine = ''
            this.waitingForOperand = false
            return
          }
          case 'ln': {
            this.inputExpr = `ln(${plain})`
            this.upperLine = ''
            this.waitingForOperand = false
            return
          }
          case 'log': {
            this.inputExpr = `log(${plain})`
            this.upperLine = ''
            this.waitingForOperand = false
            return
          }
          case 'sin': {
            this.inputExpr = `sin(${plain})`
            this.upperLine = ''
            this.waitingForOperand = false
            return
          }
          case 'cos': {
            this.inputExpr = `cos(${plain})`
            this.upperLine = ''
            this.waitingForOperand = false
            return
          }
          case 'tan': {
            this.inputExpr = `tan(${plain})`
            this.upperLine = ''
            this.waitingForOperand = false
            return
          }
        }
      }
    }

    switch (key) {
      case '1/x': {
        this.appendToken('1/(')
        break
      }

      case '√x': {
        this.appendToken('√(')
        break
      }
      case 'y√x': {
        this.appendToken('√(')
        break
      }
      case 'x²': {
        this.appendToken('^2')
        break
      }
      case 'xʸ': {
        this.appendToken('^')
        break
      }
      case 'ln':
        this.appendToken('ln(')
        break
      case 'log':
        this.appendToken('log(')
        break
      case 'sin':
        this.appendToken('sin(')
        break
      case 'cos':
        this.appendToken('cos(')
        break
      case 'tan':
        this.appendToken('tan(')
        break
      case '(':
        this.appendToken('(')
        break
      case ')':
        this.appendToken(')')
        break
      case '10ˣ':
        if (this.isInitialZero() || this.inputExpr === '0' || this.waitingForOperand) {
          this.inputExpr = '10^'
          this.upperLine = ''
          this.waitingForOperand = false
        } else {
          this.appendToken('10^')
        }
        break
      case 'x!': {
        this.appendToken('!')
        break
      }
      case 'π': {
        this.appendToken('π')
        break
      }
    }
  }

  private insertDot() {
    const seg = this.lastNumberSegment()
    if (seg.includes('.')) return
    if (seg === '' || /[^\d)]$/.test(this.inputExpr)) {
      this.appendToken('0.')
    } else {
      this.appendToken('.')
    }
  }

  private lastNumberSegment(): string {
    let i = this.inputExpr.length - 1
    let seg = ''
    while (i >= 0) {
      const ch = this.inputExpr[i]
      if (/[0-9.]/.test(ch)) {
        seg = ch + seg
      } else {
        break
      }
      i--
    }
    return seg
  }

  private toggleSign() {
    const s = this.inputExpr

    if (/^[+-]?[0-9.]+$/.test(s) || s === 'π') {
      if (s.startsWith('-')) this.inputExpr = s.slice(1)
      else this.inputExpr = '-' + s
      this.upperLine = ''
      return
    }

    const mPar = s.match(/\(0-([^\)]+)\)$/)
    if (mPar) {
      this.inputExpr = s.slice(0, s.length - mPar[0].length) + mPar[1]
      this.upperLine = ''
      return
    }

    const m = s.match(/([0-9.π]+)$/)
    if (m) {
      const atom = m[1]
      const start = s.length - atom.length
      const before = s.slice(0, start)
      if (atom.startsWith('-')) {
        this.inputExpr = before + atom.slice(1)
      } else {
        this.inputExpr = before + `(0-${atom})`
      }
      this.upperLine = ''
      return
    }

    this.inputExpr = `(0-${s})`
    this.upperLine = ''
  }


  private applyPercentToLastNumber(): void {
    const re = /([0-9.]+)%?$/
    if (re.test(this.inputExpr)) {
      this.inputExpr = this.inputExpr.replace(re, (m: string, p1: string): string => {
        if (m.endsWith('%')) return m;
        return p1 + '%';
      })
    }
  }

  private autoCloseParens(s: string): string {
    let open = 0
    let close = 0
    for (let ch of s) {
      if (ch === '(') open++
      else if (ch === ')') close++
    }
    if (open <= close) return s
    const need = open - close
    return s + ')'.repeat(need)
  }

  private evaluateAndShow() {
    const original = this.inputExpr
    const completed = this.autoCloseParens(original)

    try {
      const value = this.evalExpression(completed)
      const singleNumberRegex = /^-?[0-9.]+(?:e[+\-]?\d+)?$/i
      const parenNegRegex = /^\(0-([0-9.]+(?:e[+\-]?\d+)?)\)$/i
      let hideUpper = false

      if (singleNumberRegex.test(completed) || completed === 'π' || completed === 'PI' || parenNegRegex.test(completed)) {
        hideUpper = true
      } else {
        try {
          const toks = this.tokenize(completed)
          if (toks.length === 1 && (/^[0-9.]+(?:e[+\-]?\d+)?$/i.test(toks[0]) || toks[0] === 'PI')) {
            hideUpper = true
          } else if (toks.length === 3 && toks[0] === '0' && toks[1] === '-' && /^[0-9.]+(?:e[+\-]?\d+)?$/i.test(toks[2])) {
            hideUpper = true
          }
        } catch (e) {
        }
      }

      this.upperLine = hideUpper ? '' : completed

      this.inputExpr = this.formatNumber(value)
      this.waitingForOperand = true
    } catch (e) {
      this.upperLine = original
      this.inputExpr = 'Error'
      this.waitingForOperand = true
    }
  }


  private formatNumber(n: number): string {
    if (!isFinite(n)) return 'Error'

    if (Math.abs(n) < 1e-14) return '0'

    const intRound = Math.round(n)
    if (Math.abs(n - intRound) < 1e-12) {
      // 防止 -0 的出现
      return (intRound === 0) ? '0' : intRound.toString()
    }

    const PREC = 9
    const absn = Math.abs(n)

    if (absn >= 1e9 || (absn > 0 && absn < 1e-6)) {
      let s = n.toExponential(PREC - 1)
      const parts = s.split('e')
      parts[0] = parts[0].replace(/\.?0+$/, '')
      const exp = parts[1]
      return parts[0] + 'e' + exp
    }

    const factor = Math.pow(10, PREC)
    const rounded = Math.round(n * factor) / factor
    let s = rounded.toFixed(PREC)
    s = s.replace(/\.?0+$/, '')
    if (s === '-0') s = '0'
    return s
  }

  private tokenize(s: string): string[] {
    s = s.replace(/÷/g, '/').replace(/x/g, '*').replace(/π/g, 'PI')
    let open = 0, close = 0
    for (let ch of s) {
      if (ch === '(') open++
      else if (ch === ')') close++
    }
    while (open > close) { s += ')'; close++ }

    const tokens: string[] = []
    let i = 0
    while (i < s.length) {
      const ch = s[i]
      if (ch === ' ') { i++; continue }

      if (s[i] === '√' || s[i] === '✓') {
        const prevToken = tokens.length ? tokens[tokens.length - 1] : ''
        if (/^[0-9)π!^]+$/.test(prevToken)) {
          tokens.push('yroot')
        } else {
          tokens.push('sqrt')
        }
        i += 1
        continue
      }

      if (/[0-9.]/.test(ch)) {
        let j = i + 1
        while (j < s.length && /[0-9.]/.test(s[j])) j++
        if (j < s.length && (s[j] === 'e' || s[j] === 'E')) {
          let k = j + 1
          if (k < s.length && (s[k] === '+' || s[k] === '-')) k++
          let hasDigit = false
          while (k < s.length && /[0-9]/.test(s[k])) { hasDigit = true; k++ }
          if (hasDigit) {
            j = k
          }
        }

        let numStr = s.slice(i, j)
        while (j < s.length && s[j] === '%') {
          numStr = String(parseFloat(numStr) / 100)
          j++
        }
        tokens.push(numStr)
        i = j
        continue
      }

      if (/[()+\-*/^!]/.test(ch)) {
        if (ch === '-') {
          const prev = tokens.length ? tokens[tokens.length - 1] : undefined
          if (!prev || ['+', '-', '*', '/', '^', 'yroot', '('].includes(prev)) {
            tokens.push('0')
          }
        }
        tokens.push(ch)
        i++
        continue
      }

      if (s.startsWith('yroot', i)) {
        tokens.push('yroot')
        i += 5
        continue
      }

      const rest = s.slice(i)
      const fnMatch = /^(sin|cos|tan|ln|log|sqrt|inv|PI)/.exec(rest)
      if (fnMatch) {
        tokens.push(fnMatch[0])
        i += fnMatch[0].length
        continue
      }

      throw new Error('Bad token at ' + i)
    }

    for (let idx = 0; idx < tokens.length - 1; idx++) {
      if (tokens[idx] === '(' && tokens[idx + 1] === ')') {
        tokens.splice(idx + 1, 0, '0')
        idx++
      }
    }

    return tokens
  }

  private toRPN(tokens: string[]): string[] {
    const prec: Record<string, number> = {
      '!' : 5,
      'inv': 5, 'sqrt': 5, 'sin': 5, 'cos': 5, 'tan': 5, 'ln': 5, 'log': 5,
      '^': 4,
      'yroot': 4,
      '*': 3, '/': 3,
      '+': 2, '-': 2,
    }
    const rightAssoc: Record<string, boolean> = { '^': true }
    const out: string[] = []
    const st: string[] = []

    const isFunc = (t: string) => ['inv','sqrt','sin','cos','tan','ln','log'].includes(t)

    for (let i = 0; i < tokens.length; i++) {
      const t = tokens[i]
      if (/^[0-9.]+(?:e[+\-]?\d+)?$/i.test(t) || t === 'PI') {
        out.push(t)
      } else if (isFunc(t)) {
        st.push(t)
      } else if (t === ',') {

      } else if (t === '(') {
        st.push(t)
      } else if (t === ')') {
        while (st.length && st[st.length - 1] !== '(') {
          out.push(st.pop() as string)
        }
        if (!st.length) throw new Error('Mismatched )')
        st.pop()
        if (st.length && isFunc(st[st.length - 1])) {
          out.push(st.pop() as string)
        }
      } else if (['+','-','*','/','^','!','yroot'].includes(t)) {
        if (t === '!') {
          out.push(t)
          continue
        }
        while (st.length) {
          const top = st[st.length - 1]
          if ( (isFunc(top)) ||
            (prec[top] && (prec[top] > prec[t] || (prec[top] === prec[t] && !rightAssoc[t])) ) ) {
            out.push(st.pop() as string)
          } else break
        }
        st.push(t)
      } else {
        throw new Error('Unknown token ' + t)
      }
    }
    while (st.length) {
      const t = st.pop() as string
      if (t === '(' || t === ')') throw new Error('Mismatched ()')
      out.push(t)
    }
    return out
  }

  private getButtonBg(k: string, keys: string[]): ResourceColor {
    const OPERATORS = ['÷', '×', 'x', '-', '+', '='];
    const isOperator = OPERATORS.includes(k);
    const isFirstRow = keys.join(',') === this.row1.join(',');
    const isFirstRowSpecial = isFirstRow && ['AC','+/-','%'].includes(k);

    return isOperator ? this.ORANGE_BTN :
      (isFirstRowSpecial ? this.LIGHT_GRAY_BTN : this.DARK_GRAY_BTN);
  }

  private evalRPN(rpn: string[]): number {
    const st: number[] = []
    const pop1 = () => {
      if (!st.length) throw new Error('Bad expr')
      return st.pop() as number
    }
    const pop2 = () => {
      const b = pop1()
      const a = pop1()
      return [a, b]
    }
    for (const t of rpn) {
      if (/^[0-9.]+(?:e[+\-]?\d+)?$/i.test(t)) st.push(parseFloat(t))
      else if (t === 'PI') st.push(Math.PI)
      else if (t === '+') { let ab = pop2(); st.push(ab[0] + ab[1]) }
      else if (t === '-') { let ab = pop2(); st.push(ab[0] - ab[1]) }
      else if (t === '*') { let ab = pop2(); st.push(ab[0] * ab[1]) }
      else if (t === '/') { let ab = pop2(); st.push(ab[0] / ab[1]) }
      else if (t === '^') { let ab = pop2(); st.push(Math.pow(ab[0], ab[1])) }
      else if (t === 'yroot') { let ab = pop2(); st.push(Math.pow(ab[1], 1 / ab[0])) }
      else if (t === 'sin') { const a=pop1(); st.push(Math.sin(this.degToRadIfNeeded(a))) }
      else if (t === 'cos') { const a=pop1(); st.push(Math.cos(this.degToRadIfNeeded(a))) }
      else if (t === 'tan') { const a=pop1(); st.push(Math.tan(this.degToRadIfNeeded(a))) }
      else if (t === 'ln') { const a=pop1(); st.push(Math.log(a)) }
      else if (t === 'log') { const a=pop1(); st.push(Math.log10(a)) }
      else if (t === 'sqrt') { const a=pop1(); st.push(Math.sqrt(a)) }
      else if (t === 'inv') { const a=pop1(); st.push(1 / a) }
      else if (t === '!') { const a=pop1(); st.push(this.factorial(a)) }
      else throw new Error('Bad op ' + t)
    }
    if (st.length !== 1) throw new Error('Bad result')
    return st[0]
  }

  private degToRadIfNeeded(a: number): number {
    return a * Math.PI / 180
  }

  private factorial(x: number): number {
    if (x < 0) return NaN
    if (Math.abs(x - Math.round(x)) > 1e-12) {
      x = Math.round(x)
    }
    let n = Math.floor(x)
    let r = 1
    for (let i = 2; i <= n; i++) r *= i
    return r
  }

  private evalExpression(expr: string): number {
    const tokens = this.tokenize(expr)
    const rpn = this.toRPN(tokens)
    const val = this.evalRPN(rpn)
    return val
  }

  build() {
    Column() {
      if (this.isSci) {
        this.sciPage()
      } else {
        this.basicPage()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.BLACK)
    .justifyContent(FlexAlign.End)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }

  @Builder basicPage(): void {
    Column() {
      this.displayArea()

      Column() {
        this.basicRow(this.row1)
        this.basicRow(this.row2)
        this.basicRow(this.row3)
        this.basicRow(this.row4)
        this.basicRow(this.row5)
      }
      .justifyContent(FlexAlign.End)
      .width('100%')
      .padding({ left: 10, right: 10, bottom: 16, top: 24 })
      .backgroundColor(this.BLACK)
    }
    .width('100%')
    .padding({ top: 0 })
  }

  @Builder sciPage(): void {
    Column() {
      this.displayArea()

      Column() {
        this.sciRow(this.sci1)
        this.sciRow(this.sci2)
        this.sciRow(this.sci3)
      }
      .width('100%')
      .padding({ left: 10, right: 10, top: 8 })

      Column() {
        this.basicRow(this.row1)
        this.basicRow(this.row2)
        this.basicRow(this.row3)
        this.basicRow(this.row4)
        this.basicRow(this.row5)
      }
      .justifyContent(FlexAlign.End)
      .width('100%')
      .padding({ left: 10, right: 10, bottom: 14, top: 6 })
      .backgroundColor(this.BLACK)

    }
    .width('100%')
  }

  @Builder displayArea(): void {
    Column() {
      if (this.upperLine !== '') {
        Row() {
          Text(this.upperLine)
            .fontSize(this.smallFont)
            .fontColor(this.TXT_WHITE)
            .fontWeight(FontWeight.Medium)
            .textAlign(TextAlign.End)
            .width('100%')
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Clip })
        }.width('100%')
      } else {
        Row() {
          Text(' ')
            .fontSize(this.smallFont)
            .fontColor(this.TXT_WHITE)
            .textAlign(TextAlign.End)
            .width('100%')
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Clip })
        }.width('100%')
      }

      Row() {
        Text(this.inputExpr)
          .fontSize(this.bigFont)
          .fontColor(Color.White)
          .fontWeight(FontWeight.Bold)
          .textAlign(TextAlign.End)
          .width('100%')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Clip })
      }.width('100%')
    }
    .width('100%')
    .padding({ top: 24, left: 18, right: 18, bottom: 12 })
    .margin({ bottom: 12 })
  }


  @Builder basicRow(keys: string[]): void {
    Row() {
      ForEach(keys, (k: string) => {
        this.keyButton(
          (k === 'AC' ? 'AC' : k),
          this.getButtonBg(k, keys),
          () => {
            if (k === 'AC') {
              if (this.isInitialZero()) this.clearAll()
              else this.backspace()
            } else {
              this.onBasicKey(k)
            }
          },
          this.isSci
            ? { w: '22.5%', h: 52, r: 12 }
            : { w: '22.5%', h: 70, r: 35 }
        )
      }, (k: string) => k)
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
    .margin({ top: 10 })
  }


  @Builder sciRow(keys: string[]): void {
    Row() {
      ForEach(keys, (k: string) => {
        this.keyButton(
          this.formatSciDisplay(k),
          this.DARK_GRAY_BTN,
          () => {
            this.onSciKey(k);
          },
          { w: '18%', h: 48, r: 12 },
          14
        )
      }, (k: string) => k)
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
    .margin({ bottom: 8 })
  }

  @Builder keyButton(
    label: string,
    bg: ResourceColor,
    onTap: () => void,
    size: ButtonSize,
    fontSize: number = 24
  ): void {
    Button(label)
      .fontColor(this.TXT_WHITE)
      .fontSize(fontSize)
      .fontWeight(FontWeight.Medium)
      .backgroundColor(bg)
      .borderRadius(size.r)
      .width(size.w)
      .height(size.h)
      .onClick(() => {
        onTap()
      })
      .margin({ bottom: 6 })
  }

}
