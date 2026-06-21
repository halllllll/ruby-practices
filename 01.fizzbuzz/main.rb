def fizzbuzz(n)
  answer = ""
  if n % 3 == 0
    answer += "Fizz"
  end
  if n % 5 == 0
    answer += "Buzz"
  end

  if answer.empty?
    n.to_s
  else
    answer
  end
end

(1..20).each do |n|
  puts fizzbuzz(n)
end
