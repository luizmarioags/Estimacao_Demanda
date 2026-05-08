# Visualizações incluídas

Este pacote inclui scripts de visualização em R, Stata e Python. Os gráficos são apenas auxiliares para apresentação e interpretação dos resultados econométricos.

## Figuras principais

1. `01_series_temporais_variaveis_principais`: mostra a evolução de `qc`, `pf`, `y`, `pb` e `pc`.
2. `02_scatter_qc_pf_mqo`: mostra a relação bruta entre quantidade e preço do galeto, com reta MQO.
3. `03_coeficientes_beta_p_mqo_2sls`: compara a elasticidade-preço por MQO e por 2SLS nas especificações `Z1` a `Z10`.
4. `04_f_instrumentos_por_modelo`: mostra a F efetiva do `weakivtest` quando a tabela Stata existe; caso contrário, usa F robusta auxiliar de primeiro estágio.
5. `05_primeiro_estagio_scatter_instrumentos`: mostra a relação entre `pf` e instrumentos selecionados.
6. `06_residuos_versus_ajustados_mqo`: ajuda a discutir indícios visuais de heterocedasticidade.
