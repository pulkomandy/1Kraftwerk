#include <stdio.h>
#include <stdint.h>
#include <unistd.h>
#include <netinet/in.h>

#define NANOSVG_IMPLEMENTATION
#include "nanosvg.h"

/* Converts an SVG file into defb/defw statements wit points coordinates.
 */

int main(void)
{
	NSVGimage* image = nsvgParseFromFile("kraftwerk.svg", "px", 96);

	for (NSVGshape * shape = image->shapes; shape != NULL; shape = shape->next)
	{
		uint8_t color;
		switch(shape->fill.color)
		{
			case 0xFF000000: // black
				color = 1;
				break;
			case 0xffffffff: // white
				color = 2;
				break;
			default:
				fprintf(stderr, "\nUnknown color %x\n", shape->fill.color);
		}

		printf("\tdefw ");

		for (NSVGpath * path = shape->paths; path != NULL; path = path->next)
		{
			int16_t x = 0, y = 0;
			for (int i = 0; i < path->npts; i+=3)
			{
				int16_t X = path->pts[i * 2];
				int16_t Y = 400 - path->pts[i * 2 + 1];

				printf("%d, %d, ", X - x, Y - y);
				x = X; y = Y;
			}
		}

		printf("0xFFFF\n");
	}

	nsvgDelete(image);

	return 0;
}
