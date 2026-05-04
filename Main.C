#include "xgpio.h"
#include "xparameters.h"
#include "xil_printf.h"
#include "sleep.h"
//#include <xgpio.h>
#include <xil_types.h>

XGpio gpio0;
XGpio gpio1;

int main() {
 //not using while(1) becuse I wanat to see if this alone works  
xil_printf("1\n");
XGpio_Initialize(&gpio0, XPAR_AXI_GPIO_0_BASEADDR);
xil_printf("2\n");
XGpio_Initialize(&gpio1, XPAR_AXI_GPIO_1_BASEADDR);
xil_printf("3\n");
//
u32 test0 = XGpio_DiscreteRead(&gpio0, 1);
u32 test1 = XGpio_DiscreteRead(&gpio1, 1);
xil_printf("GPIO 0 is OK. Value: %d\n", test0);
xil_printf("GPIO 1 is OK. Value: %d\n", test1);

    return 0;
}
