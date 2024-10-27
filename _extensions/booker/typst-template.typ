// color palette settings
#let main_color = rgb(5, 142, 217)
#let secondary_color = main_color.rotate(180deg)
#let accent_color = secondary_color.rotate(10deg).saturate(90%)
#let cover_page_color = main_color.rotate(180deg).rotate(180deg).desaturate(50%)

// constrast ratio function for the cover page between the text and the background color

#let relative_luminance((r, g, b, a)) = {
  return 0.2126 * r + 0.7152 * g + 0.0722 * b
}

#let contrast_ratio(color1, color2)= {
  let rl1 = relative_luminance(color1.components())
  let rl2 = relative_luminance(color2.components())
  return calc.max((rl1 + 5%) / (rl2 + 5%), (rl2 + 5%) / (rl1 + 5%))
}

// fonts settings
#let dark_text = rgb(15, 10, 10)
#let cover_page_text = main_color.rotate(180deg).negate()

#if contrast_ratio(cover_page_color, cover_page_text) < 4.5 {
  if relative_luminance(cover_page_color.components()) > 50% {
    cover_page_text = cover_page_color.darken(80%)
  } else {
    cover_page_text = cover_page_color.lighten(80%)
  }
} else { cover_page_text = cover_page_text }
#let cover_page_line = cover_page_color.saturate(99%).rotate(180deg).negate()

#let version_box(body) = {
  box(
    fill: main_color.lighten(90%),
    inset: 0.1em,
    outset: 0.1em,
    stroke: (paint: main_color, thickness: 0.3pt, dash: "solid"),
    radius: 0.3em,
    body,
  )
}

#let blockquote(body) = {
  block(
    width: 100%,
    fill: secondary_color.lighten(90%),
    inset: 2em,
    stroke: (
      left: (paint: accent_color.lighten(50%), thickness: 0.1em, dash: "solid"),
    ),
    radius: 0.3em,
    body,
  )
}


#show quote: it => {
  blockquote(it)
}


#let grid_2(body1, body2)= {
  align(horizon, grid(columns: 2, gutter: 1em, [#body1], [#body2]))
}



#let example_counter = counter("example")

#let blockexample(body) = {
  grid_2(
    box(stroke: (bottom: main_color),
      [E.g. #example_counter.display()]),
    box(
      align(body, left), 
      stroke: main_color,
       fill: main_color.lighten(80%), 
      outset: 1em)
      )
    example_counter.step()
}

#let example(body) = {
  figure(kind: "example", supplement: [E.g.], blockexample(body))
}



#let main_fonts = ("Latin Modern Roman","IBM Plex Serif", "Merriweather")
#let secondary_fonts = ("IBM Plex Sans", "Source Sans Pro", "Noto Sans")
#let math_fonts = ("MathJax_Math", "New Computer Modern Math")
#let mono_fonts = ("Iosevka NF", "Monolisa", "STIX MathJax Monospace")

#let book(
  title: none,
  subtitle: none,
  author: none,
  logo: none,
  date: none,
  version: none,
  figure-index: (enabled: false, title: ""), // Display an index of figures (images).
  table-index: (enabled: false, title: ""), // Display an index of tables
  listing-index: (enabled: false, title: ""), // Display an index of listings (code blocks).
  body,
)= {
  // Set the document's metadata.
  set document(title: title)
  set cite(style: "american-geophysical-union")

  // Set Cover page
  set page(paper: "a4")
  set text(hyphenate: false)
  set par(justify: true)
  
  page(
    background: rect(fill: cover_page_color, width: 100%, height: 100%),
    margin: (top: 6em, bottom: 6em, left: 5em, right: 5em),
    header: grid(
      columns: (1fr, 1fr, 1fr),
      [#if logo != none {
          image(logo, height: 3em)
        }],
      [],
      text(
        size: 1em,
        fill: cover_page_text,
        weight: 400,
        font: main_fonts,
      )[VERSION | *#version*],
      align: (left + horizon, center + horizon, right),
    ),
    box(
      grid( // the box is only for the top stroke
        columns: (1fr),
        rows: (2fr, 0.8fr, 0.8fr),
        grid(columns: 1, gutter: 4em, box(text(
          size: 2em,
          fill: cover_page_text,
          weight: 500,
          font: secondary_fonts,
          align(upper(title), right),
        ), width: 90%, stroke: (right: cover_page_line), inset: 1em), box(text(
          size: 1.3em,
          fill: cover_page_text,
          weight: 400,
          font: secondary_fonts,
          align(subtitle, left),
        ), width: 90%, inset: 1em, stroke: (left: cover_page_line))),
        [],
        grid(columns: (1fr, 1fr, 1fr), text(
          size: 1.3em,
          fill: cover_page_text,
          weight: 200,
          font: secondary_fonts,
        )[#author], [], text(
          size: 1.3em,
          fill: cover_page_text,
          weight: 400,
          font: secondary_fonts,
        )[#date], align: (left, center, right)),
        align: center + horizon,
      ),
      stroke: (top: cover_page_line + 0.1em),
    ),
  )

  set par(justify: true)
  set block(spacing: 2em) // space between paragraphs
  set text(font: main_fonts, size: 10pt, weight: 300, hyphenate: false)
  show math.equation: set text(font: math_fonts, size: 10pt)


  // show raw: set text(font: mono_fonts, size: 9pt)
  // show raw: body => {
  //   align(left, rect(
  //     inset: (top: 1em, bottom: 1em, left: -7em, right: -7em),
  //     outset: (top: 1em, bottom: 1em, left: 15em, right: 15em),
  //     fill: luma(95%),
  //     stroke: (paint: main_color, thickness: 0.2em),
  //     radius: 1em,
  //     width: 100%,
  //     [#underline[R code example:] #body],
  //   ))
  // }

  // Configure footer
  
  set page(margin: (inside: 3.5cm, outside: 3.5cm, y: 3cm), footer: grid(
    columns: (1fr, 1fr, 1fr),
    align: (left, center, right),
    gutter: 0.5em,
    [],
    [],
    align(counter(page).display("1 of 1", both: true), right),
  ))
//   context {
//   let chapter = query(selector(heading).before(here())).slice(-1).at(0)

//     // Config header
//   set page(header: grid(
//     columns: (1fr, 1fr, 1fr),
//     align: (left, center, right),
//     gutter: 0.5em,
//     [],
//     [],
//     [chapter.body],


//   ))
// }





  // Set bulette list settings
  set list(
    tight: false,
    indent: 1.5em,
    body-indent: 1em,
    spacing: auto,
    marker: ([•], [--], [○], [‣]))

  // Set number list settings
  set enum(
    tight: false,
    indent: 1.5em,
    body-indent: 1em,
    spacing: auto,
  )


  // Crossref settings
  show ref : it =>[
    #h(0.3em)
    #set text(weight: "regular", font: mono_fonts, size: 0.8em)
    #box(
      [#it],
      stroke: accent_color + 0.04em,
      fill: secondary_color.lighten(90%),
      outset: 0.2em,
      radius: 0.2em,
    )
    #h(0.3em)
  ]

  // Link settings
  show link : it =>[
    #h(0.3em)
    #set text(weight: "regular")
    #box(
      [#it],
      stroke: main_color + 0.04em,
      fill: main_color.lighten(90%),
      outset: 0.2em,
      radius: 0.2em,
    )
    #h(0.3em)
  ]
  show cite : it =>[
    #h(0.3em)
    #set text(weight: "regular")
    #box(
      [#it],
      stroke: main_color + 0.04em,
      fill: main_color.lighten(90%),
      outset: 0.2em,
      radius: 0.2em,
    )
    #h(0.3em)
  ]


  // Headings settings
  set heading(numbering: (..nums) => {
    let sequence = nums.pos()
    // discard first entry (chapter number)
    let _ = sequence.remove(0)
    if sequence.len() > 0 {
      numbering("1.", ..sequence)
    }
  })


  show heading.where(level: 1): it => {
    set text(fill: secondary_color.darken(65%), weight: 1000, size: 1.5em)
    set align(right)
    pagebreak(weak: true)
    block(
      smallcaps(it),
      outset: (top: 5em, bottom: 0em, left: 10em, right: 10em),
      inset: (top: 5em, bottom: -1em, rest: 0em),
      fill: main_color.desaturate(70%).lighten(80%),
      width: 100%,
      stroke: (bottom: main_color + 0.03em),
    )
  v(1.5em)
  }

  show heading: set block(inset:  (top: 0.5em, bottom: 2em, rest: 0em))

  show heading.where(level: 2): set text(fill: main_color.darken(30%), weight: 600, size: 1.3em)
  show heading.where(level: 3): set text(fill: main_color.darken(30%), weight: 400, size: 1.1em)
  show heading.where(level: 4): set text(fill: main_color.darken(50%), weight: 400, size: 1.05em)
  show heading.where(level: 5): set text(fill: secondary_color.darken(50%), weight: 400, size: 1em)
  show heading.where(level: 6): set text(fill: secondary_color.darken(50%), weight: 300, size: 1em)
  show heading.where(level: 7): set text(fill: secondary_color.darken(50%), weight: 300, size: 1em)
  show heading.where(level: 8): set text(fill: secondary_color.darken(50%), weight: 300, size: 1em)

  show heading: set text(font: mono_fonts)
  // Figure settings
  show figure.caption: it =>{
    v(0.3em)
    set text(
      fill: accent_color.darken(70%),
      weight: 400,
      size: 0.8em,
      font: mono_fonts,
    )
    block(it)
  }



  // Table settings
  show figure.where(kind: table): set figure.caption (position: top)
  show figure.where(kind: table): set block(breakable: true)
  show figure.where(kind: table):set table.header(repeat: true) // TODO: not working!
  set table(
    // Increase the table cell's padding
    fill: (_, y) => {
      if (calc.odd(y)) {
        return accent_color.lighten(90%).desaturate(90%);
      } else if (y == 0) {
        return main_color.lighten(80%).desaturate(50%);
      }
    },
    inset: 0.7em,
    stroke: (_, y) => {
      if (y == 0) {
        return (bottom: main_color, rest: none);
      } else {
        return none;
      }
    },
  )
  show table.cell.where(y: 0): strong
  show table: set text(size: 0.7em)
  set terms(indent: 1em, separator: " - ")


  // add table of content
  show outline.entry: it =>{
    text([#it], size: 0.9em)
  }
  show outline.entry.where(level: 1): it => [
    #v(0.1em)
    #text(
      it,
      fill: main_color.darken(50%),
      size: 1em,
      font: secondary_fonts,
      weight: 700,
    )
  ]

  show outline.entry: set text(font: main_fonts, weight: 300)
  outline(indent: auto, depth: 5)

  // document body
  body

  // Display indices of figures, tables, and listings.
  let fig-t(kind) = figure.where(kind: kind)
  let has-fig(kind) = counter(fig-t(kind)).get().at(0) > 0
  if figure-index.enabled or table-index.enabled or listing-index.enabled {
    show outline: set heading(outlined: true)
    context {
      let imgs = figure-index.enabled and has-fig(image)
      let tbls = table-index.enabled and has-fig(table)
      let lsts = listing-index.enabled and has-fig(raw)
      if imgs or tbls or lsts {
        pagebreak()
      }

      if imgs {
        outline(
          title: figure-index.at("title", default: "Index of Figures"),
          target: fig-t(image),
        )
      }
      if tbls {
        outline(
          title: table-index.at("title", default: "Index of Tables"),
          target: fig-t(table),
        )
      }
      if lsts {
        outline(
          title: listing-index.at("title", default: "Index of Listings"),
          target: fig-t(raw),
        )
      }
    }
  }
}

