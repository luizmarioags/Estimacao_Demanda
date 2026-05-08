# Lista 1 - Economia Industrial: Estimação de Função Demanda

Pacote de replicação para a **Lista de Exercícios 1: Estimação de Função Demanda**.

Este pacote implementa, em **Stata**, **R** e **Python**, a estimação da demanda por galeto:

$$
q_c = \beta_0 + \beta_p p_f + \beta_I y + \beta_b p_b + \varepsilon
$$

onde:

- `qc = log(Q)`: log do consumo per capita de galeto;
- `pf = log(PCHICK/CPI)`: log do preço real do galeto;
- `y = log(Y)`: log da renda real per capita;
- `pb = log(PBEEF/CPI)`: log do preço real da carne vermelha;
- `pc = log(PCOR/CPI)`: log do preço real do milho, usado como instrumento.

A rotina segue a lógica do capítulo de estimação de demanda para produto homogêneo: o preço é tratado como variável potencialmente endógena, e a identificação de `beta_p` é feita via variáveis instrumentais/2SLS usando deslocadores de custo/oferta.

## Novidades desta versão

Esta versão adiciona:

1. **download automático da base `broiler.csv`**;
2. **scripts de visualização** em R, Stata e Python;
3. geração automática de figuras em `output/figures/`.

A base é baixada do problem set de Industrial Organization do MIT OCW mirror:

```text
https://mitocw.ups.edu.ec/courses/economics/14-271-industrial-organization-i-fall-2005/assignments/broiler.csv
```

O arquivo é salvo como:

```text
data/raw/chicken_demand.csv
```

## Observação importante sobre o teste de instrumentos fracos

O **Stata é a rotina principal para o item de instrumentos fracos**, porque o exercício pede o teste F eficiente de Montiel Olea e Pflueger, operacionalizado pelo comando:

```stata
weakivtest
```

O script Stata roda `weakivtest` após cada regressão `ivreg2` e salva `r(F_eff)` na tabela final.

Os scripts em R e Python são auxiliares para reproduzir MQO, primeiro estágio, 2SLS e gráficos, mas **não substituem o `weakivtest` do Stata**.

## Estrutura

```text
lista1EI_replication_package_v4_downloads_plots/
├── data/
│   ├── raw/                 # base original baixada automaticamente
│   └── processed/           # base tratada será salva aqui
├── output/
│   ├── tables/              # tabelas finais
│   ├── logs/                # logs
│   └── figures/             # gráficos finais
├── R/
│   ├── 00_setup.R
│   ├── 00_download_data.R
│   ├── 01_prepare_data.R
│   ├── 02_ols.R
│   ├── 03_first_stage.R
│   ├── 04_iv_2sls.R
│   ├── 05_run_all.R
│   └── 06_visualizations.R
├── Stata/
│   ├── config.do
│   ├── 00_download_data.do
│   ├── 00_master.do
│   ├── 01_prepare_data.do
│   ├── 02_ols.do
│   ├── 03_first_stage.do
│   ├── 04_iv_2sls_weakivtest.do
│   └── 05_visualizations.do
├── Python/
│   ├── requirements.txt
│   └── src/
│       ├── config.py
│       ├── download_data.py
│       ├── prepare_data.py
│       ├── ols.py
│       ├── first_stage.py
│       ├── iv_2sls.py
│       ├── visualizations.py
│       └── run_all.py
└── docs/
    ├── codebook.md
    └── metodologia.md
```

## Como rodar no Stata

Abra o Stata no diretório raiz do pacote e execute:

```stata
do Stata/00_master.do
```

Saídas principais:

```text
output/tables/stata_ols_results.csv
output/tables/stata_first_stage_results.csv
output/tables/stata_iv_results_weakivtest.csv
output/figures/*.png
```

## Como rodar no R

No R/RStudio, com o diretório de trabalho na raiz do pacote:

```r
source("R/05_run_all.R")
```

Saídas principais:

```text
output/tables/r_ols_results.csv
output/tables/r_first_stage_results.csv
output/tables/r_iv_results.csv
output/figures/*.png
```

## Como rodar no Python

No terminal, a partir da raiz do pacote:

```bash
python -m venv .venv
# Windows:
.venv\Scripts\activate
# Linux/Mac:
# source .venv/bin/activate

pip install -r Python/requirements.txt
python Python/src/run_all.py
```

Saídas principais:

```text
output/tables/python_ols_results.csv
output/tables/python_first_stage_results.csv
output/tables/python_iv_results.csv
output/figures/*.png
```

## Gráficos gerados

Os scripts de visualização geram:

1. séries temporais das variáveis principais;
2. dispersão entre `qc` e `pf` com reta MQO;
3. gráfico de coeficientes de `beta_p`, comparando MQO e 2SLS;
4. gráfico da F efetiva do `weakivtest`, se a tabela Stata existir; caso contrário, F robusta auxiliar do primeiro estágio;
5. gráficos de primeiro estágio entre `pf` e instrumentos selecionados;
6. resíduos versus valores ajustados no MQO.

## Especificações de instrumentos

| Modelo | Instrumentos excluídos |
|---|---|
| Z1 | `pc` |
| Z2 | `pc`, `pc^2` |
| Z3 | `pc`, `pc^2`, `pc^3` |
| Z4 | `pc(t-1)` |
| Z5 | `pc(t-1)`, `pc(t-1)^2` |
| Z6 | `exp(pc)` |
| Z7 | `exp(pc)`, `exp(pc^2)` |
| Z8 | `exp(pc)`, `exp(pc^2)`, `exp(pc^3)` |
| Z9 | `exp(pc(t-1))` |
| Z10 | `exp(pc(t-1))`, `exp(pc(t-1)^2)` |

## Interpretação esperada

1. MQO estima a demanda ignorando endogeneidade de preço.
2. 2SLS instrumenta `pf` com deslocadores do custo/oferta ligados ao milho.
3. O primeiro estágio avalia se os instrumentos explicam o preço real do galeto, condicionalmente a `y` e `pb`.
4. O `weakivtest` avalia se os instrumentos são fracos usando a estatística F efetiva de Montiel Olea-Pflueger.
5. A tabela final deve comparar como `beta_p`, o intervalo de confiança e a F efetiva mudam de `Z1` a `Z10`.

## Notas de implementação

- Os erros-padrão são robustos à heterocedasticidade.
- As defasagens usam `TIME` para ordenar a série anual.
- Os modelos com defasagem perdem a primeira observação.
- `exp(pc)` corresponde a retirar o log do preço real do milho.
- `exp(pc^2)` foi implementado literalmente como `exp((log preço real do milho)^2)`, pois esta é a forma escrita na lista.
