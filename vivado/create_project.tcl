# Run from Vivado Tcl console: source vivado/create_project.tcl
set project_name washing_machine_basys3
set project_dir [file normalize "./vivado_project"]
create_project $project_name $project_dir -part xc7a35tcpg236-1 -force
set_property board_part digilentinc.com:basys3:part0:1.2 [current_project]
add_files [list rtl/debounce.v rtl/seg7_mux.v rtl/washing_machine_ctrl.v rtl/basys3_washing_machine.v]
add_files -fileset constrs_1 vivado/constraints/basys3_washing_machine.xdc
set_property top basys3_washing_machine [current_fileset]
add_files -fileset sim_1 tb/tb_washing_machine.v
set_property top tb_washing_machine [get_filesets sim_1]
update_compile_order -fileset sources_1
update_compile_order -fileset sim_1
