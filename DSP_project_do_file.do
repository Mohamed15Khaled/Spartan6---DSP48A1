vlib work
vlog register_or_not.v DSP_project.v DSP_project_tb.v
vsim -voptargs=+acc work.DSP_project_tb
add wave *
run -all
#quit -sim