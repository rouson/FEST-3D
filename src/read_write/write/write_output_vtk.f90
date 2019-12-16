  !< Vtk module to write the solution in the vtk format
module write_output_vtk
  !< Vtk module to write the solution in the vtk format
  !---------------------------------------------------------
  ! This module write state + other variable in output file
  !---------------------------------------------------------
#include "../../debug.h"
#include "../../error.h"
  use vartypes
  use global     , only : OUT_FILE_UNIT
  use global     , only : OUTIN_FILE_UNIT
  use global     , only : outin_file

  use global_vars, only : density
  use global_vars, only : x_speed
  use global_vars, only : y_speed
  use global_vars, only : z_speed
  use global_vars, only : pressure
  use global_vars, only : tk
  use global_vars, only : tw
  use global_vars, only : tkl
  use global_vars, only : tv
  use global_vars, only : tgm
  use global_vars, only : te
  use global_vars, only : mu
  use global_vars, only : mu_t
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
  use global_vars, only : Tv_residue
  use global_vars, only : intermittency

!  use global_vars, only : w_count
!  use global_vars, only : w_list

  use global_sst , only : sst_F1
  use gradients, only : gradu_x
  use gradients, only : gradu_y
  use gradients, only : gradu_z
  use gradients, only : gradv_x
  use gradients, only : gradv_y
  use gradients, only : gradv_z
  use gradients, only : gradw_x
  use gradients, only : gradw_y
  use gradients, only : gradw_z
  use gradients, only : gradT_x
  use gradients, only : gradT_y
  use gradients, only : gradT_z
  use gradients, only : gradtk_x
  use gradients, only : gradtk_y
  use gradients, only : gradtk_z
  use gradients, only : gradtw_x
  use gradients, only : gradtw_y
  use gradients, only : gradtw_z

  use utils

  implicit none
  private
  integer :: i,j,k
  integer :: imx, jmx, kmx

  public :: write_file

  contains

    subroutine write_file(nodes, control, dims)
      !< Write the header and variables in the file "process_xx.dat"
      implicit none
      type(controltype), intent(in) :: control
      type(extent), intent(in) :: dims
      type(nodetype), dimension(-2:dims%imx+3,-2:dims%jmx+3,-2:dims%kmx+3), intent(in) :: nodes 
      integer :: n
      character(len=*), parameter :: err="Write error: Asked to write non-existing variable- "
      DebugCall("write_file")

      imx = dims%imx
      jmx = dims%jmx
      kmx = dims%kmx

      call write_header(control%Write_data_format)
      call write_grid(nodes)

      do n = 1,control%w_count

        select case (trim(control%w_list(n)))

          case('Velocity')
            call write_velocity()

          case('Density')
            call write_scalar(density ,"Density", -2)

          case('Pressure')
            call write_scalar(pressure ,"Pressure", -2)

          case('Mu')
            call write_scalar(mu ,"Mu", -2)

          case('Mu_t')
            call write_scalar(mu_t, "Mu_t", -2)

          case('TKE')
            call write_scalar(tk, "TKE", -2)

          case('Omega')
            call write_scalar(tw, "Omega", -2)

          case('Kl')
            call write_scalar(tkl, "Kl", -2)

          case('tv')
            call write_scalar(tv, "tv", -2)

          case('tgm')
            call write_scalar(tgm, "tgm", -2)

          case('Dissipation')
            call write_scalar(te, "Dissipation", -2)

          case('Wall_distance')
            call write_scalar(dist, "dist", -2)

          case('TKE_residue')
            call write_scalar(TKE_residue ,"TKE_residue", 1)

          case('Tv_residue')
            call write_scalar(Tv_residue ,"Tv_residue", 1)

          case('F1')
            call write_scalar(sst_F1 ,"F1", -2)

          case('Dudx')
            call write_scalar(gradu_x ,"dudx ", 0)

          case('Dudy')
            call write_scalar(gradu_y ,"dudy ", 0)

          case('Dudz')
            call write_scalar(gradu_z ,"dudz ", 0)

          case('Dvdx')
            call write_scalar(gradv_x ,"dvdx ", 0)

          case('Dvdy')
            call write_scalar(gradv_y ,"dvdy ", 0)

          case('Dvdz')
            call write_scalar(gradv_z ,"dvdz ", 0)

          case('Dwdx')
            call write_scalar(gradw_x ,"dwdx ", 0)

          case('Dwdy')
            call write_scalar(gradw_y ,"dwdy ", 0)

          case('Dwdz')
            call write_scalar(gradw_z ,"dwdz ", 0)

          case('DTdx')
            call write_scalar(gradT_x ,"dTdx ", 0)

          case('DTdy')
            call write_scalar(gradT_y ,"dTdy ", 0)

          case('DTdz')
            call write_scalar(gradT_z ,"dTdz ", 0)

          case('Dtkdx')
            call write_scalar(gradtk_x,"dtkdx", 0)

          case('Dtkdy')
            call write_scalar(gradtk_y,"dtkdy", 0)

          case('Dtkdz')
            call write_scalar(gradtk_z,"dtkdz", 0)

          case('Dtwdx')
            call write_scalar(gradtw_x,"dtwdx", 0)

          case('Dtwdy')
            call write_scalar(gradtw_y,"dtwdy", 0)

          case('Dtwdz')
            call write_scalar(gradtw_z,"dtwdz", 0)

          case('Intermittency')
            call write_scalar(intermittency, "Intermittency", -2)
          
          case('do not write')
            ! do nothing
            continue

          case Default
            print*, err//trim(control%w_list(n))//" to file"

        end select
      end do


    end subroutine write_file


    subroutine write_header(Write_data_format)
        !< Write the header in the output file in the tecplot format
        implicit none
        character(len=*), intent(in) :: Write_data_format

        DebugCall("write_header")

        write(OUT_FILE_UNIT, fmt='(a)') '# vtk DataFile Version 3.1'
        write(OUT_FILE_UNIT, '(a)') 'cfd-iitm output'   ! comment line
        write(OUT_FILE_UNIT, '(a)') trim(Write_data_format)
        write(OUT_FILE_UNIT, '(a)') 'DATASET STRUCTURED_GRID'
        !write(OUT_FILE_UNIT, *)


    end subroutine write_header

    subroutine write_grid(nodes)
        !< Write the grid information in the output file
        implicit none
        type(nodetype), dimension(-2:imx+3,-2:jmx+3,-2:kmx+3), intent(in) :: nodes 

        ! write grid point coordinates
        DebugCall("write_grid")
        write(OUT_FILE_UNIT, fmt='(a, i0, a, i0, a, i0)') &
            'DIMENSIONS ', imx, ' ', jmx, ' ', kmx
        write(OUT_FILE_UNIT, fmt='(a, i0, a)') &
            'POINTS ', imx*jmx*kmx, ' DOUBLE'
        do k = 1, kmx
         do j = 1, jmx
          do i = 1, imx
              write(OUT_FILE_UNIT, fmt='(f0.16, a, f0.16, a, f0.16)') &
                  nodes(i, j, k)%x, ' ', nodes(i, j, k)%y, ' ', nodes(i, j, k)%z
          end do
         end do
        end do
        write(OUT_FILE_UNIT, *)

    end subroutine write_grid

    subroutine write_velocity()
        !< Write the velocity vector in the output file
        implicit none
        DebugCall("write_velocity")

        ! Cell data
        ! Writing Velocity
        write(OUT_FILE_UNIT, fmt='(a, i0)') 'CELL_DATA ', (imx-1)*(jmx-1)*(kmx-1)
        write(OUT_FILE_UNIT, '(a)') 'VECTORS Velocity FLOAT'
        do k = 1, kmx - 1
         do j = 1, jmx - 1
          do i = 1, imx - 1
            write(OUT_FILE_UNIT, fmt='(ES27.16E4, a, ES27.16E4, a, ES27.16E4)') &
                x_speed(i, j, k), ' ', y_speed(i, j, k), ' ', z_speed(i, j, k)
          end do
         end do
        end do
        write(OUT_FILE_UNIT, *)

    end subroutine write_velocity



    subroutine write_scalar(var, name, index)
        !< Write the scalar variable in the output file
        implicit none
        integer, intent(in) :: index
        real, dimension(index:imx-index,index:jmx-index,index:kmx-index), intent(in) :: var
        character(len=*),       intent(in):: name

        DebugCall("write_scalar: "//trim(name))

        write(OUT_FILE_UNIT, '(a)') 'SCALARS '//trim(name)//' FLOAT'
        write(OUT_FILE_UNIT, '(a)') 'LOOKUP_TABLE default'
        do k = 1, kmx - 1
         do j = 1, jmx - 1
          do i = 1, imx - 1
            write(OUT_FILE_UNIT, fmt='(ES25.16E4)') var(i, j, k)
          end do
         end do
        end do
        write(OUT_FILE_UNIT, *)

    end subroutine write_scalar


end module write_output_vtk
