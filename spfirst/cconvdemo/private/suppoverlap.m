function supp = suppoverlap(supp1,supp2)
if length(supp1)==1 & length(supp2)==1
   % Two impulses
   if supp1 == supp2
      supp = supp1;
   else
      supp = [];
   end
elseif length(supp1)==1
   % One impulse
   if (supp2(1)<supp1) & (supp1<supp2(2))
      supp = supp1;
   else
      supp = [];
   end
elseif length(supp2) == 1
   % One impulse
   if (supp1(1)<supp2) & (supp2<supp1(2))
      supp = supp2;
   else
      supp = [];
   end
else
   % Neither is an impulse
   a = supp1(1);
   b = supp1(2);
   c = supp2(1);
   d = supp2(2);
   supp = sort([supp1 supp2]);
   if all(supp==[a b c d]) | all(supp==[c d a b])
      supp = [];
   elseif all(supp([1 end])==[a b])
      supp = [c d];
   elseif all(supp([1 end])==[c d])
      supp = [a b];
   elseif supp([1 end])==[a d]
      supp = [c b];
   else
      supp = [a d];
   end
end
