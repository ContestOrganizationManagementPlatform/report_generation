#set page(flipped: true, margin: 0pt, paper: "us-letter")

#let award_date = "April 13th, 2024"
#let data = json.decode(sys.inputs.data)
#let name = data.name

#let layout_award(award, test) = {
  image("certificate_base.svg")

  set text(size: 45pt, font: "Oswald")

  place(
    top + center,
    dy: 230pt,
    text(weight: "bold", name),
  )

  place(
    top + center,
    dy: 330pt,
    text(weight: "bold", award),
  )

  place(
    top + center,
    dy: 382pt,
    text(weight: "bold", size: 23pt, test),
  )
}

#for achievement in data.achievements {
  layout_award(achievement.award, achievement.test)
}

