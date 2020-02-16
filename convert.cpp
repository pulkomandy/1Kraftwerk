#include <stdio.h>
#include <stdint.h>
#include <unistd.h>
#include <netinet/in.h>

#define NANOSVG_IMPLEMENTATION
#include "nanosvg.h"

/* Converts an SVG file into a Lua array suitable for display in GRafX2 with
 * test.lua. I'll probably be too lazy to fully automate the conversion from
 * that to the syntax required by the assembler again, and use some search and
 * replace in vim.
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
			for (int i = 0; i < path->npts; i+=3)
			{
				int16_t X = path->pts[i * 2];
				int16_t Y = 400 - path->pts[i * 2 + 1];

				printf("%d, %d, ", X, Y);
			}
		}

		printf("0xFFFF\n");
	}

	nsvgDelete(image);

	return 0;
}
