program day6_part1
    implicit none

    integer :: io
    character(len=10) :: rec_type
    integer :: times(4)
    integer :: records(4)
    integer :: running_total

    integer :: race_id
    integer :: count
    integer :: x

    integer :: time
    integer :: distance

    running_total = 1

    open(newunit=io, file="../input.txt", status="old", action="read")
    read(io, *) rec_type, times
    read(io, *) rec_type, records
    close(io)

    do race_id = 1, 4
        count = 0

        do x = 1, times(race_id)
            time = times(race_id) - x
            distance = time * x

            if (distance > records(race_id)) then
                count = count + 1
            end if
        end do

        if (count == 0) then
            cycle
        end if

        print *, 'Race: ', race_id, ' Count: ', count
        running_total = running_total * count
    end do

    print *, 'Total: ', running_total

end program day6_part1
