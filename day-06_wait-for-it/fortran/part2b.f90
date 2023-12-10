program day6_part1
    use iso_fortran_env
    implicit none

    integer :: io
    character(len=10) :: rec_type
    integer :: times(4)
    integer :: records(4)

    integer(kind=int64) :: race_time
    integer(kind=int64) :: race_record

    character(len=10) :: tmp_a
    character(len=20) :: tmp_b

    real(kind=real64) :: float_time
    real(kind=real64) :: float_record


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

    float_time = race_time
    float_record = race_record

    print *, float_time
    print *, float_record

    print *, 'Total: ', floor(sqrt((float_time*float_time) - (float_record*4)))

end program day6_part1
