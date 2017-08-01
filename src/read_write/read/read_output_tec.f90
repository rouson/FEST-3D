module read_output_tec
  !---------------------------------------------------------
  ! This module read state + other variable in output file
  !---------------------------------------------------------
  use global     , only : OUT_FILE_UNIT
  use global     , only : OUTIN_FILE_UNIT
  use global     , only : outin_file

  use global_vars, only : read_data_format
  use global_vars, only : read_file_format
  use global_vars, only : imx
  use global_vars, only : jmx
  use global_vars, only : kmx
  use global_vars, only : grid_x
  use global_vars, only : grid_y
  use global_vars, only : grid_z
  use global_vars, only : density 
  use global_vars, only : x_speed 
  use global_vars, only : y_speed 
  use global_vars, only : z_speed 
  use global_vars, only : pressure 
  use global_vars, only : tk 
  use global_vars, only : tw 
  use global_vars, only : mu 
  use global_vars, only : mu_t 
  use global_vars, only : density_inf
  use global_vars, only : x_speed_inf
  use global_vars, only : y_speed_inf
  use global_vars, only : z_speed_inf
  use global_vars, only : pressure_inf 
  use global_vars, only : gm
  use global_vars, only : dist
  use global_vars, only : vis_resnorm
  use global_vars, only : cont_resnorm
  use global_vars, only : x_mom_resnorm
  use global_vars, only : y_mom_resnorm
  use global_vars, only : z_mom_resnorm
  use global_vars, only : energy_resnorm
  use global_vars, only : resnorm
  use global_vars, only :   mass_residue
  use global_vars, only :  x_mom_residue
  use global_vars, only :  y_mom_residue
  use global_vars, only :  z_mom_residue
  use global_vars, only : energy_residue
  use global_vars, only : TKE_residue

  use global_vars, only : turbulence
  use global_vars, only : mu_ref
  use global_vars, only : current_iter
  use global_vars, only : max_iters
  use global_vars, only : r_count
  use global_vars, only : r_list

  use global_sst , only : sst_F1
  use global_vars, only : gradu_x
  use global_vars, only : gradu_y
  use global_vars, only : gradu_z
  use global_vars, only : gradv_x
  use global_vars, only : gradv_y
  use global_vars, only : gradv_z
  use global_vars, only : gradw_x
  use global_vars, only : gradw_y
  use global_vars, only : gradw_z
  use global_vars, only : gradT_x
  use global_vars, only : gradT_y
  use global_vars, only : gradT_z
  use global_vars, only : gradtk_x
  use global_vars, only : gradtk_y
  use global_vars, only : gradtk_z
  use global_vars, only : gradtw_x
  use global_vars, only : gradtw_y
  use global_vars, only : gradtw_z
  use global_vars, only : process_id

  use utils
  use string

  implicit none
  private
  integer :: i,j,k
  public :: read_file

  contains

    subroutine read_file()
      implicit none
      integer :: n

      call read_header()
      call read_grid()

      do n = 1,r_count

        select case (trim(r_list(n)))
        
          case('Velocity')
            call read_scalar(x_speed, "u", -2)
            call read_scalar(y_speed, "v", -2)
            call read_scalar(z_speed, "w", -2)

          case('Density')
            call read_scalar(density, "Density", -2)
          
          case('Pressure')
            call read_scalar(pressure, "Pressure", -2)
            
          case('TKE')
            call read_scalar(tk, 'TKE', -2)

          case('Omega')
            call read_scalar(tw, 'Omega', -2)

          case('do not read')
            !skip 
            continue

          case Default
            Print*, "read error: list var : "//trim(r_list(n))

        end select
      end do

    end subroutine read_file


    subroutine read_header()
      implicit none
      integer :: n

      call dmsg(1, 'read_output_tec', 'read_header')
      read(OUT_FILE_UNIT, *) !"variables = x y z "

      do n = 1,r_count
        read(OUT_FILE_UNIT, *) !trim(w_list(n))
      end do

      read(OUT_FILE_UNIT, *) ! "zone T=block" ...
      read(OUT_FILE_UNIT, *) !"Varlocation=([1-3]=Nodal)"
      read(OUT_FILE_UNIT, *) !"Varlocation=([4-",total,"]=CELLCENTERED)"

    end subroutine read_header


    subroutine read_grid()
      implicit none
      real :: dummy

      ! read grid point coordinates
      call dmsg(1, 'read_output_tec', 'read_grid')
      read(OUT_FILE_UNIT, *) (((dummy,i=1,imx), j=1,jmx), k=1,kmx)
      read(OUT_FILE_UNIT, *) (((dummy,i=1,imx), j=1,jmx), k=1,kmx)
      read(OUT_FILE_UNIT, *) (((dummy,i=1,imx), j=1,jmx), k=1,kmx)

    end subroutine read_grid

    subroutine read_scalar(var, name, index)
      implicit none
      integer, intent(in) :: index
      real, dimension(index:imx-index,index:jmx-index,index:kmx-index), intent(out) :: var
      character(len=*),       intent(in):: name

      call dmsg(1, 'read_output_tec', trim(name))
      read(OUT_FILE_UNIT, *) (((var(i, j, k),i=1,imx-1), j=1,jmx-1), k=1,kmx-1)

    end subroutine read_scalar


end module read_output_tec