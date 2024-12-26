# Cut and paste from library for simplicity
NN ← (>⟜«0⊸≤) / 0(0⊸≤××⟜10⊸+)`⊢

ToNums ← {
  T←⌈`× ⋄ I1T←(1+↕∘≠)⊸T
  cd←≠dig←('0'+↕10)∾"π∞" ⋄ val←(↕10)∾π‿1‿¯1 # ∞ as 1 to avoid ∞×0
  e‿d‿n‿p‿i←"e.¯π∞"=<𝕩 ⋄ e‿n∨↩"E-"=<𝕩
  m←cd>j←dig⊐𝕩 ⋄ d‿e‿n∧↩(»(∨<⊸∾∧⋈⊢)«)n∨m∨d ⋄ m∨↩d
  s←d∨c←e∨z←(tr←∧`⌾⌽zz)<»⊸<zz←¬e∨n∨m
  "Negative sign in the middle of a number"! ∧´n≤1»zz∨c
  "Portion of a number is empty"! ∧´¬(1«s∨tr)∧n∨s
  "Ill-formed decimal or exponent use"! ∧´(0⊸=∨»⊸<)s/d+2×e
  "π and ∞ must occur alone"! ∧´(p∨i)≤1(»∧(p∧«e)∨«)zz∨n>»e
  l←(¬(⊢-T)·+`d⊸<)g←(«≤(d<jz←j≠0)>○I1T¬)⊸∧m # No leading 0s
  la←d×(»¬(⊢-T)+`)⌾⌽¬g∨jz                   # Adjust dp for dropped 0s after decimal
  k‿dp←d¬⊸(/⋈1⊸»⊸/)○((d∨>⟜«g)⊸/)l-la        # Length, decimal position
  PN←NN val⊏˜(«⊸>∨d⊸<)/j⌈cd×¬
  va←{                                      # Numeric values—mantissas and exponents
    ¬∨´k>15?PN g;                           # If >15 digits anywhere:
    g∧↩20≥l⋄k⌊↩20                           # Cap at 20 digits
    g>↩f←g∧l≤(+`»⊸<g)⊏0∾te←0⌈k-15           # Handle trailing ≤15 normally
    (1e15×PN f)⊸+⌾((te>0)⊸/) PN g           # Leading part
  }
  v←va×1‿¯1⊏˜(r←>⟜»m)/»n                    # Negate if ¯
  vm←c/○(1⌾⊑)z                              # Mask of mantissas in v
  mn←vm/v×(r/i)⊏1‿∞                         # Mantissa, correcting ∞
  ee←vm/(k-dp)-˜«v×¬vm                      # Power of 10
  a←(0⌈ee)+ee-b←ee⌈¯308                     # Subnormal handling
  b÷⟜(10⋆-)˜⌾((0>b)⊸/)a 10⊸⋆⊸×⌾((0≠a)⊸/)mn  # mn×10⋆ee
}
# End of cut and paste

i ← •file.Lines "../levels.txt"

r ← ToNums¨i

Ord ← ∧⊸(≡∨≡⟜⌽)
Dif ← ∧´1=1‿4⍋·|¯1↓-⟜«
Safe ← Dif∧Ord

•Show p1 ← +´ s ← Safe¨r

r /˜↩ ¬s
•Show p1 +´(∨´·Safe˘⊢/⎉1˜·≠⌜˜·↕≠)¨r