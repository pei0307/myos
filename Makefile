
GPPPARAMS = -m32 -fno-use-cxa-atexit -nostdlib -fno-builtin -fno-rtti -fno-exceptions -fno-leading-underscore
ASPARAMS = --32
LDPARAMS =  -melf_i386

objects = loader.o gdt.o port.o kernel.o 

%.o: %.cpp
	g++ $(GPPPARAMS) -o $@ -c $<
	
%.o: %.s
	as $(ASPARAMS) -o $@ $<
	
mykernel.bin: linker.ld $(objects)
	ld $(LDPARAMS) -T $< -o $@ $(objects)

mykernel.iso: mykernel.bin
	mkdir iso
	mkdir iso/boot
	mkdir iso/boot/grub
	cp $< iso/boot/
	echo 'set timeout=0' >>  iso/boot/grub/grub.cfg
	echo 'set default=0' >>  iso/boot/grub/grub.cfg
	echo '' >>  iso/boot/grub/grub.cfg
	echo 'menuentry "My Operating System" {' >>  iso/boot/grub/grub.cfg
	echo ' multiboot /boot/mykernel.bin' >>  iso/boot/grub/grub.cfg
	echo ' boot' >>  iso/boot/grub/grub.cfg
	echo ' }' >>  iso/boot/grub/grub.cfg
	grub-mkrescue --output=$@ iso
	rm -rf iso
	sudo cp $@ /media/psf/Home/mykernel.iso


install:mykernel.bin
	sudo cp $< /boot/mykernel.bin

run: mykernel.iso
	(killall VirtailBox && sleep 1) || true
	VirtualBox --startvm "My Operating System" &
runs: 
	# prlctl delete myos
	# prlctl create myos --ostype other
	prlctl stop myos --kill
	prlctl set myos --device-set cdrom0 --image '/Users/pei/mykernel.iso' --enable --connect 	
	prlctl start myos
 