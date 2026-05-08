# Metodologia econométrica

## 1. Modelo de demanda

A demanda agregada é estimada como:

$$
q_c = \beta_0 + \beta_p p_f + \beta_I y + \beta_b p_b + \varepsilon.
$$

Como todas as variáveis relevantes estão em logaritmo, $\beta_p$ é a elasticidade-preço própria da demanda.

## 2. Problema de endogeneidade

Em mercados de produto homogêneo, preço e quantidade são determinados simultaneamente pelo equilíbrio de oferta e demanda. Portanto, o preço observado pode estar correlacionado com o erro da equação de demanda. Nesse caso, MQO pode ser inconsistente.

## 3. Estratégia de variáveis instrumentais

O preço real do milho é usado como deslocador de custo/oferta. A intuição é que choques no preço do milho afetam o custo de produção do galeto e, portanto, o preço do galeto, mas não deveriam deslocar diretamente a demanda por galeto após controlar por renda e preço da carne vermelha.

A condição de relevância é avaliada pelo primeiro estágio:

$$
p_f = \pi_0 + Z \pi + \gamma_I y + \gamma_b p_b + v.
$$

A condição de exogeneidade é substantiva e deve ser defendida economicamente.

## 4. 2SLS

A segunda etapa usa a variação prevista de $pf$ pelo conjunto de instrumentos $Z$, mantendo os controles $y$ e $p_b $.

## 5. Instrumentos fracos

O pacote usa `weakivtest` no Stata depois de `ivreg2`. A estatística relevante para a lista é a F efetiva de Montiel Olea-Pflueger, retornada por `r(F_eff)`.

A hipótese nula do teste é de instrumentos fracos. Assim, valores altos da F efetiva levam à rejeição da hipótese de instrumentos fracos.

## 6. Sobre heterocedasticidade

Há motivação econômica para usar erros robustos: os dados são uma série temporal agregada longa, com mudanças de escala, tecnologia, renda, população e padrões de consumo. Nada garante que a variância dos choques de demanda seja constante ao longo do tempo.
