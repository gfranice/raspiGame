ARMGNU ?= aarch64-linux-gnu
SRC_DIR = src
CONFIG_DIR = config
BIN_DIR = binaries

AOPS = -g --warn --fatal-warnings
ASM_SRCS = $(wildcard $(SRC_DIR)/*.s)
ASM_OBJS = $(ASM_SRCS:$(SRC_DIR)/%.s=$(BIN_DIR)/%.o)

.PHONY: clean prepare

all: prepare kernel8.img

prepare:
	mkdir -p $(BIN_DIR)

$(BIN_DIR)/%.o: $(SRC_DIR)/%.s
	$(ARMGNU)-as $(AOPS) $< -o $@

clean:
	rm -rf *.o $(BIN_DIR)

kernel8.img: prepare $(ASM_OBJS)
	$(ARMGNU)-ld $(ASM_OBJS) -T $(CONFIG_DIR)/memmap -o $(BIN_DIR)/kernel8.elf -M > $(BIN_DIR)/memory_map.txt
	$(ARMGNU)-objdump -D $(BIN_DIR)/kernel8.elf > $(BIN_DIR)/kernel8.list
	$(ARMGNU)-objcopy $(BIN_DIR)/kernel8.elf -O binary $(BIN_DIR)/kernel8.img

runQEMU: kernel8.img
	qemu-system-aarch64 -M raspi3b -kernel $(BIN_DIR)/kernel8.img -serial stdio -qtest unix:/tmp/qtest.sock,server,nowait

runGPIOM: bin/gpiom
	./bin/gpiom

runGDB:
	gdb-multiarch -ex "set architecture aarch64" -ex "target remote localhost:1234" --ex "dashboard registers -style list 'x0 x1 x2 x3 x4 x5 x6 x7 x8 x9 x10 x11 x12 x13 x14 x15 x16 x17 x18 x19 x20 x21 x22 x23 x24 x25 x26 x27 x28 x29 x30 sp pc cpsr'"