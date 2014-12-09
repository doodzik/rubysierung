#include "rubysierung.h"

VALUE rb_mRubysierung;

void
Init_rubysierung(void)
{
  rb_mRubysierung = rb_define_module("Rubysierung");
}
