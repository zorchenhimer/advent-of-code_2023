program day6_part2
    use iso_fortran_env
    implicit none

    integer :: io
    character(len=10) :: rec_type
    !character(len=0) :: rec_val(4)
    integer :: times(4)
    integer :: records(4)
    integer(kind=int64) :: running_total

    integer(kind=int64) :: race_time
    integer(kind=int64) :: x
    integer(kind=int64) :: race_record

    integer(kind=int64) :: count
    integer(kind=int64) :: time
    integer(kind=int64) :: distance
    character(len=10) :: tmp_a
    character(len=20) :: tmp_b

    running_total = 1

    open(newunit=io, file="../input.txt", status="old", action="read")

    read(io, *) rec_type, times
    read(io, *) rec_type, records
    close(io)

    print *, 'times:   ', times
    print *, 'records: ', records

    print '(i2i2i2i2)', times
    write(tmp_a, '(i2i2i2i2)') times
    read(tmp_a, *) race_time
    print *, 'race time: ', race_time

    print '(i0i0i0i0)', records
    write(tmp_b, '(i0i0i0i0)') records
    read(tmp_b, *) race_record
    print *, 'race record: ', race_record

    count = 0

    do x = 1, race_time
        time = race_time - x
        distance = time * x

        if (distance > race_record) then
            count = count + 1
        end if
    end do

    !print *, 'Race: ', race_id, ' Count: ', count
    !running_total = running_total * count

    print *, 'Total: ', count

end program day6_part2
