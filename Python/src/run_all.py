from download_data import main as download_data
from prepare_data import main as prepare_data
from ols import main as run_ols
from first_stage import main as run_first_stage
from iv_2sls import main as run_iv
from visualizations import main as run_visualizations


def main():
    download_data()
    prepare_data()
    run_ols()
    run_first_stage()
    run_iv()
    run_visualizations()
    print("Replicação Python concluída.")
    print("Atenção: para a estatística F efetiva de Montiel Olea-Pflueger, rode o pacote Stata com weakivtest.")


if __name__ == "__main__":
    main()
