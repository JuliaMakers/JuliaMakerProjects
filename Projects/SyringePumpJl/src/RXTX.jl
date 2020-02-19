function drive_pump( mcu::SerialPort, steps::Int, mus_p_step::Int = convert(Int64, round(3e5)) )
    try
        write(mcu, "$mus_p_step,$steps")
        flush(mcu)
        println("$mus_p_step,$steps")
    catch
        @warn "Could not write to microcontroller! Is the correct serial port being used?"
    end
    return nothing
end

stop_pump( mcu::SerialPort ) = drive_pump( mcu, 0, 100 )

function drive_physical(mcu::SerialPort, cd::CalibrationData, vol_per_step, vol, time;
                        steps_per_rot::Float64 = 200.0, sec_per_min = 60.0u"s/minute")
    disp            = cd.beta ± cd.beta_uncertainty
    total_steps     = disp * value( vol ) * value( vol_per_step ) #steps/mL * mL = steps
    sec_per_step    = value( time ) / total_steps
    us_per_step     = sec_per_step * 1000000
    drive_pump( mcu, abs(Int( round( total_steps.val ) )), Int( round( us_per_step.val ).val ) )
    return nothing
end
