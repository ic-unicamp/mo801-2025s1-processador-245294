test_srcs := $(wildcard *.s)
test_elfs := $(test_srcs:%.s=%.elf)
test_bins := $(test_srcs:%.s=%.bin)
test_mems := $(test_srcs:%.s=%.mem)

%.elf: %.s
	riscv32-unknown-linux-gnu-gcc -march=rv32i -mabi=ilp32 -nostdlib -T linker.ld -o $@ $<

%.bin: %.elf
	riscv32-unknown-linux-gnu-objcopy -O binary $< $@

%.mem: %.bin
	hexdump -v -e '1/4 "%08x""\n"' $< > $@

$(test_mems): $(test_srcs) $(test_elfs) $(test_bins)

all: $(test_mems)

install: $(test_mems)
	cp $(test_mems) ../test

clean:
	rm -f $(test_elfs) $(test_bins) $(test_mems)
