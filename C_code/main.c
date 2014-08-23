#include "AdaptTempering.h"
#include "AdaptTemperingMultiBin.h"
#include <stdlib.h>

int main()
{
	at_t * at;
	int index, n = 1000;
	double Eest;
  double *varr = NULL;
	FILE *output = fopen("output.txt", "w");
	FILE *Eav = fopen("../test_set/Eav.txt", "r");
	FILE *Efluc = fopen("../test_set/Efluc.txt", "r");

	at = AdaptTempering_MasterCreate("at.cfg", 0, 1, 0);

	/* force change the at->mb->sums */
	for(index = 0; index <= n; index++) {
		at->mb->sums[index].s = 1;
		fscanf(Eav, "%lf", &(at->mb->sums[index].se));
		fscanf(Efluc, "%lf", &(at->mb->sums[index].se2));
	}
	
	fclose(Eav);
	fclose(Efluc);

	/* calc the Eest */
	for(index = 0; index < n; index++){
		Eest = mb_calc_et(at->mb, index, MB_LOOSE);

		fprintf(output, "%6.3f\n", Eest);		
	}

	fclose(output);

	AdaptTempering_Close(at);
}

