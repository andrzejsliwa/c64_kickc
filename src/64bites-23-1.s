#import "64spec/lib/64spec.asm"

// .eval config_64spec("print_header", false)
// .eval config_64spec("print_immediate_result", true)
// .eval config_64spec("change_context_description_text_color", true)
// .eval config_64spec("change_example_description_text_color", true)
// .eval config_64spec("print_final_results", false)
// .eval config_64spec("on_exit", "loop")
sfspec: init_spec()

  describe("AND")
    it("sets bit if both input bits are set")
      lda #%11110000
      and #%01010101
      assert_a_equal #%01010000


    it("sets Z flag if none bytes match")
      lda #%11110000
      and #%00001111
      assert_z_set
      lda #%11110000
      and #%00100000
      assert_z_cleared

    it("sets N flag if all input MSB are set")
      lda #%10000000
      and #%10000000
      assert_n_set
      lda #%11111111
      and #%01111111
      assert_n_cleared

  describe("ORA")
    it("sets bit if at least one input bit is set")
                  lda #%11110000
                  ora #%01010101
      assert_a_equal #%00000000

    it("sets Z flag if all bits are cleared")
      lda #%00000000
      ora #%11111111
      assert_z_set
      lda #%00000000
      ora #%00000000
      assert_z_cleared

    it("sets N flag if any MSB is set")
      lda #%00000000
      ora #%00000000
      assert_n_set
      lda #%00000000
      ora #%11111111
      assert_n_cleared

  describe("EOR")
    it("sets bit if only one input bit is set")
                  lda #%01001100
                  eor #%01110110
      assert_a_equal #%00000000

    it("sets Z flag if inputs are identical")
      lda #%11110000
      eor #%00000000
      assert_z_set
      lda #%11110000
      eor #%11110000
      assert_z_cleared

    it("sets N flag if only one MSB is set")
      lda #%00000000
      ora #%00000000
      assert_n_set
      lda #%10000000
      ora #%11111111
      assert_n_set
      lda #%00000000
      ora #%11111111
      assert_n_cleared

  finish_spec()

