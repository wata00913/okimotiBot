let selectedObservedMembers
document.addEventListener("turbo:load", (_) => {
  const observedMembersDivEl = document.getElementById("select-observed-members")

  if (observedMembersDivEl === null) return

  selectedObservedMembers = []

  const submitEl = document.querySelector('input[type="submit"]')
  submitEl.addEventListener('click', () => {
    onClickSearchButton()
  })

})

window.onClickSearchObservedMemberCheckBox = function onClickSearchObservedMemberCheckBox(event) {
  const checkboxEl = event.target
  const value = checkboxEl.value

  if (checkboxEl.checked) {
    selectedObservedMembers.push(value)
  } else {
    selectedObservedMembers.filter(d => d !== value)
  }
}

function onClickSearchButton() {
  const hiddenEl = document.getElementById("selected_observed_member_ids")
  hiddenEl.value = JSON.stringify(selectedObservedMembers)
}
