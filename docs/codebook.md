# Codebook

## Variáveis originais esperadas

| Variável | Descrição |
|---|---|
| `Q` | Consumo per capita de galeto/frango |
| `Y` | Renda real disponível per capita |
| `PCHICK` | Índice nominal de preço do galeto/frango |
| `PBEEF` | Índice nominal de preço da carne vermelha |
| `PCOR` | Índice de preço do milho |
| `CPI` | Índice de preços ao consumidor |
| `TIME` | Tendência temporal: 0 para 1909, 1 para 1910, etc. |
| `PC` | Opcional: preço real do galeto, `PCHICK/CPI` |
| `PB` | Opcional: preço real da carne, `PBEEF/CPI` |

## Variáveis geradas

| Variável | Fórmula | Uso |
|---|---|---|
| `price_chick_real` | `PC` se existir; senão `PCHICK/CPI` | preço real do galeto |
| `price_beef_real` | `PB` se existir; senão `PBEEF/CPI` | preço real da carne vermelha |
| `price_corn_real` | `PCOR/CPI` | preço real do milho |
| `qc` | `log(Q)` | variável dependente |
| `pf` | `log(price_chick_real)` | variável endógena |
| `y` | `log(Y)` | controle de renda |
| `pb` | `log(price_beef_real)` | controle/substituto |
| `pc` | `log(price_corn_real)` | instrumento básico |
| `pc2` | `pc^2` | instrumento transformado |
| `pc3` | `pc^3` | instrumento transformado |
| `pc_l1` | `pc(t-1)` | instrumento defasado |
| `pc2_l1` | `pc_l1^2` | instrumento defasado transformado |
| `exp_pc` | `exp(pc)` | preço real do milho sem log |
| `exp_pc2` | `exp(pc^2)` | transformação literal da lista |
| `exp_pc3` | `exp(pc^3)` | transformação literal da lista |
| `exp_pc_l1` | `exp(pc_l1)` | preço real defasado sem log |
| `exp_pc2_l1` | `exp(pc_l1^2)` | transformação literal da lista |
