let selectedObservedMembers
document.addEventListener("turbo:load", (_) => {
  const selectObservedMembersDivEl = document.getElementById("select-observed-members")

  if (selectObservedMembersDivEl === null) return

  selectedObservedMembers = []
  const checkboxesEl = document.querySelectorAll("#observed-members input[type=checkbox]")
  checkboxesEl.forEach(checkboxEl => synchronizeSelectedObservedMembers(checkboxEl))

  const submitEl = document.querySelector('input[type="submit"]')
  submitEl.addEventListener('click', () => {
    onClickSearchButton()
  })
})

window.onClickSearchObservedMemberCheckBox = function onClickSearchObservedMemberCheckBox(event) {
  const checkboxEl = event.target
  synchronizeSelectedObservedMembers(checkboxEl)
}

function onClickSearchButton() {
  const hiddenEl = document.getElementById("selected_observed_member_ids")
  hiddenEl.value = JSON.stringify(selectedObservedMembers)
}

function synchronizeSelectedObservedMembers(checkboxEl) {
  const value = checkboxEl.value
  const index = selectedObservedMembers.findIndex(d => d === value)

  if (index === -1 && checkboxEl.checked) {
    selectedObservedMembers.push(value)
  } else if (index !== -1 && !checkboxEl.checked) {
    selectedObservedMembers.splice(index, 1)
  }
}
